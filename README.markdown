# term_extract - Term Extract

## Description:

term_extract extracts proper nouns (named things like 'Manchester United') and ordinary nouns (like 'event') from text documents.

## Usage:

An example extracting terms from a piece of content:

    require 'term_extract'

    content = <<DOC
    Business Secretary Vince Cable will stay in cabinet despite
    "declaring war" on Rupert Murdoch, says Downing Street.
    DOC

    terms = TermExtract.extract(content)

## Options

The #extract method takes an (optional) options hash, that allows the term extractor behaviour to be modified.  The following options are available:

* min_occurance - The minimum number of times a single word term must occur to be included in the results, default 3
* min_terms - Always include multiword terms that comprise more than @min_terms words, default 2
* types - Extract proper nouns (:nnp) or nouns (:nn) or both (:all), default :all
* include_tags - Include the extracted POS tags in the results, default false
* collapse_terms - Remove shorter terms that are part of larger ones, default true

Sample usage:

    terms = TermExtract.extract(content, :types => :nnp, :include_tags => true)

## Term Extraction Types

By default, the term extractor attempts to extract both ordinary nouns and proper nouns, this behaviour can be configured using the #types option and specifying :all (for both), :nn (for ordinary nouns) or :nnp (for proper nouns).  These codes correspond to the relevent POS tags used during the term extraction process.  Sample usage is shown below:

    terms = TermExtract.extract(content, :types => :nnp)

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with Rakefile, version, or history as it's handled by Jeweler.
* Send me a pull request. I may or may not accept it.

## Acknowledgements

The algorithm and extraction code is based on the original python code at:

http://pypi.python.org/pypi/topia.termextract/

## Copyright and License

GPL v3 - See LICENSE.txt for details.
Copyright (c) 2010, Rob Lee

