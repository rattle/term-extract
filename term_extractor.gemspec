# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{term_extractor}
  s.version = "0.0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["rattle"]
  s.date = %q{2010-03-12}
  s.email = %q{robl[at]rjlee.net}
  s.files = [
    "lib/term_extractor.rb"
  ]
  s.homepage = %q{}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Provides term extraction functionality}
  s.test_files = [
    "test/test_term_extractor.rb",
     "test/test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rbtagger>, [">= 0.0.0"])
    else
      s.add_dependency(%q<rbtagger>, [">= 0.0.0"])
    end
  else
    s.add_dependency(%q<rbtagger>, [">= 0.0.0"])
  end
end
