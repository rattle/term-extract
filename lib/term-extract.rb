require 'rbtagger'

# Based on :
# http://pypi.python.org/pypi/topia.termextract/

class TermExtract

  @@SEARCH=0
  @@NOUN=1

  @@TAGGER = Brill::Tagger.new

  attr_accessor :min_occurance, :min_terms, :types, :include_tags, :lazy

  # Provide a class method for syntactic sugar
  def self.extract(content, options = {})
    te = new(options)
    te.extract(content)
  end

  def initialize(options = {})
    # The minimum number of times a single word term must occur to be included in the results
    @min_occurance = options.key?(:min_occurance) ? options.delete(:min_occurance) : 3
    # Always include multiword terms that comprise more than @min_terms words
    @min_terms = options.key?(:min_terms) ? options.delete(:min_terms) : 2
    # Extract proper nouns (:nnp) or nouns (:nn) or both (:all)
    @types = options.key?(:types) ? options.delete(:types) : :all
    # Include the extracted POS tags in the results
    @include_tags = options.key?(:include_tags) ? options.delete(:include_tags) : false
    # Remove shorter terms that are part of larger ones
    @collapse_terms = options.key?(:collapse_terms) ? options.delete(:collapse_terms) : true
    #@lazy = options.key?(:lazy) ? options.delete(:lazy) : false
  end

  def extract(content)

    # Tidy content punctuation
    # Add a space after periods
    content.gsub!(/([A-Za-z0-9])\./, '\1. ')
    
    # Assign POS tags and tidy tag stack
    tagger = @@TAGGER.nil? ? Brill::Tagger.new : @@TAGGER
    tags = preprocess_tags(tagger.tag(content))

    # Set pos tags that identify nouns
    pos = "^NN"
    case @types
    when :nn
      pos = "^(NN|NNS)$"
    when :nnp
      pos = "^(NNP|NNPS)$"
    end

    terms = Hash.new()
    multiterm = []
    last_tag = ''
    state = @@SEARCH

    # Iterate through term list and identify nouns
    tags.each do |term,tag|

      if state == @@SEARCH and tag =~ /#{pos}/
        # In search mode, found a noun
        state = @@NOUN
        add_term(term, tag, multiterm, terms)
      elsif state == @@SEARCH and tag == 'JJ' and term =~ /^[A-Z]/ #and @lazy
        # Allow things like 'Good' at the start of sentences
        state = @@NOUN
        add_term(term, tag, multiterm, terms)
      elsif state == @@NOUN and tag == 'POS'
        # Allow nouns with apostrophes : St Paul's Cathedral
        multiterm << [term,tag]
      elsif state == @@NOUN and last_tag =~ /^(NNP|NNPS)$/ and tag == 'IN' and term =~ /(of|for|on|of\sthe|\&|d\'|du|de)/i
        # Allow preposition : "Secretary of State"
        # Only use when in NNP mode
        multiterm << [term,tag]
      elsif state == @@NOUN and tag =~ /^NN/
        # In noun mode, found a noun, add a multiterm noun
        add_term(term, tag, multiterm, terms)
      elsif state == @@NOUN and tag !=~ /#{pos}/
        # In noun mode, found a non-noun, do we have a possible multiterm ?
        state = @@SEARCH
        add_multiterm(multiterm, terms) if multiterm.length > 1
        multiterm = []
      end
      last_tag = tag
    end

    # Check the last term wasn't a possible multiterm
    add_multiterm(multiterm, terms)  if last_tag =~ /#{pos}/

    # Filter out terms that don't meet minimum requirements
    # It's possible for a term with multiple words to be returned even if it doesn't
    # meet the min_occurance requirements (as a multiterm noun is very likely to be
    # correct)
    terms.each_key do |term|
      occur = terms[term][:occurances]
      strength = term.split(/ /).length
      terms.delete(term) if occur < 1
      terms.delete(term) unless ((strength == 1 and occur >= @min_occurance) or (strength >= @min_terms))
    end

    # Remove shorter terms that form part of larger terms
    # This typically removes surname references when we already have a full name
    # This doesn't test that the larger term has more occurrences than the smaller
    # term as testing has shown issues with this approach
    if @collapse_terms
      terms.each_key do |term1|
        terms.each_key do |term2|
          terms.delete(term2) if term1.length > term2.length && (term1 =~ /[^A-Za-z0-9]#{Regexp.escape(term2)}$/ || term1 =~ /^#{Regexp.escape(term2)}[^A-Za-z0-9]/)
        end
      end
    end

    # Filter out tags unless required
    unless @include_tags
      terms.each_key { |term| terms[term] = terms[term][:occurances] }
    end
    terms
  end

  protected  
  def preprocess_tags(pos)
    # Add in full stops to tag list to allow multiterms to work
    tags = []
    pos.each do |tag|
      if tag[0] =~ /\.$/
        tag[0].chop!
        tags.push tag
        tags.push ['.', '.']
      else
         tags.push tag
      end
    end
    # Join certain prepositions together to allow them to be extracted
    # e.g. allows 'News of the World' to be extracted
    tags.each_with_index do |tag, index|
      if tag[0] == 'of' && (index + 1) < tags.length && tags[index+1][0] == 'the'
        tags[index][0] = 'of the'
        tags.delete_at(index+1)
      end
    end
    tags
  end

  def add_term(term, tag, multiterm, terms)
    multiterm << ([term, tag])
    increment_term(term, tag, terms)
  end

  def add_multiterm(multiterm, terms)
    multiterm.each { |rec| terms[rec[0]][:occurances] -=1 if terms.key?(rec[0]) && terms[rec[0]][:occurances] > 0 }
    word = ''
    multiterm.each_with_index do |term, index|
      if (multiterm[index] == multiterm.last && term[1] == 'POS')
        # Don't add a final 's if it's the last term
      elsif (multiterm[index] == multiterm.last && term[1] == 'IN' ||
             multiterm[index] == multiterm.last && term[1] == 'JJ')
        # Don't add a final preposition if it's the last term
      else
        # Don't require a space for POS type concats
        word+= term[1] == 'POS' ? term[0] : " #{term[0]}"
      end
    end
    word.lstrip!
    # Add the term
    increment_term(word, 'NNP', terms)
  end

  def increment_term(term, tag, terms)
    if terms.key?(term)
      terms[term][:occurances] += 1
    else
      terms[term] = {}
      terms[term][:occurances] = 1
    end
    terms[term][:tag] = tag
  end
  
end
