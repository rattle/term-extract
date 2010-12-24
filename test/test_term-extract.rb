require 'helper'
require 'pp'

class TestTermExtract < Test::Unit::TestCase

  @@DOC1 = <<DOC1
The London Stock Exchange is a stock exchange located in London, United Kingdom.
Founded in 1801, it is one of the largest stock exchanges in the world, with many
overseas listings as well as British companies. The exchange is part of the
London Stock Exchange Group and so sometimes referred to by the ticker symbol
for the group, LSE. Its current premises are situated in Paternoster Square
close to St Paul's Cathedral in the City of London
DOC1

  @@DOC2 = <<DOC2
Secretary of State Owen Paterson has appointed Peter Osborne as Chair of the
Parades Commission for Northern Ireland and six new Commission members.
DOC2

  @@DOCUMENT = <<SOURCE
Police shut Palestinian theatre in Jerusalem.

Israeli police have shut down a Palestinian theatre in East Jerusalem.

The action, on Thursday, prevented the closing event of an international
literature festival from taking place.

Police said they were acting on a court order, issued after intelligence
indicated that the Palestinian Authority was involved in the event.

Israel has occupied East Jerusalem since 1967 and has annexed the
area. This is not recognised by the international community.

The British consul-general in Jerusalem , Richard Makepeace, was
attending the event.

"I think all lovers of literature would regard this as a very
regrettable moment and regrettable decision," he added.

Mr Makepeace said the festival's closing event would be reorganised to
take place at the British Council in Jerusalem.

The Israeli authorities often take action against events in East
Jerusalem they see as connected to the Palestinian Authority.

Saturday's opening event at the same theatre was also shut down.

A police notice said the closure was on the orders of Israel's internal
security minister on the grounds of a breach of interim peace accords
from the 1990s.

These laid the framework for talks on establishing a Palestinian state
alongside Israel, but left the status of Jerusalem to be determined by
further negotiation.

Israel has annexed East Jerusalem and declares it part of its eternal
capital.

Palestinians hope to establish their capital in the area.
SOURCE

  @@TERMS = [
    'British Council',
    'British consul-general',
    'East Jerusalem',
    'Israel',
    'Israeli authorities',
    'Israeli police',
    'Mr Makepeace',
    'Palestinian Authority',
    'Palestinian state',
    'Palestinian theatre',
    'Palestinians hope',
    'Richard Makepeace',
    'court order',
    #'event',
    'literature festival',
    'peace accords',
    'police notice',
    'security minister'
  ]

  context "Without a default term extractor" do

    should "extract terms from a document" do
      terms = TermExtract.extract(@@DOCUMENT)
      @@TERMS.each do |term|
        assert terms.keys.include?(term), "#{term} not found"
      end
    end

  end

  context "With a default term extractor" do

    setup do
      @te = TermExtract.new()
    end

    should "extract terms from a document" do
      terms = @te.extract(@@DOCUMENT)
      @@TERMS.each do |term|
        assert terms.keys.include?(term), "#{term} not found"
      end
    end

    should "extract terms with apostrophes in" do
      terms = @te.extract(@@DOC1)
      assert terms.keys.include?("St Paul's Cathedral")
    end

    should "extract terms with prepositions" do
      terms = @te.extract(@@DOC2)
      assert terms.keys.include?("Secretary of State Owen Paterson")
    end

    should "extract terms with long prepositions" do
      terms = @te.extract(@@DOC2)
      assert terms.keys.include?("Chair of the Parades Commission for Northern Ireland")
    end

    should "collapse duplicate terms" do
      terms = @te.extract(@@DOC2)
      assert !terms.keys.include?("event")
    end

    should "extract common nouns when configured to" do
      @te.types = :nn
      terms = @te.extract(@@DOCUMENT)
      assert terms.length == 11
    end

    context "with min_occurance set to 2" do

      setup do
        @te.min_occurance=2
      end

      should "extract terms that occur equal to or more than min_occurance" do
        terms = @te.extract(@@DOCUMENT)
        assert terms.keys.include?("Police")
        assert terms['Police'] == @te.min_occurance
      end

    end

    context "with min_terms set to 3" do

      setup do
        @te.min_terms=3
      end

      should "extract terms that have the same number of words as min_terms" do
        terms = @te.extract(@@DOCUMENT)
        assert terms.keys.include?("Saturday's opening event")
      end

    end

    context "with include_tags set to true" do

      setup do
        @te.include_tags=true
      end

      should "include pos tags in the results" do
        terms = @te.extract(@@DOCUMENT)
        term = terms.keys.first
        assert terms[term].key?(:tag)
        assert terms[term][:tag]
      end

    end

  end

end

