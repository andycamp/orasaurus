# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "orasaurus/version"

Gem::Specification.new do |s|
  s.name        = "orasaurus"
  s.version     = Orasaurus::VERSION
  s.authors     = ["Andy Campbell"]
  s.email       = ["pmacydna@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Tools for building Oracle Applications}
  s.description = %q{Tools for building Oracle Applications}

  s.rubyforge_project = "orasaurus"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
