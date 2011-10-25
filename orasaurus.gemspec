# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "orasaurus/version"

Gem::Specification.new do |s|
  s.name        = "orasaurus"
  s.version     = Orasaurus::VERSION
  s.authors     = ["Andy Campbell"]
  s.email       = ["andrewthomascampbell@gmail.com"]
  s.homepage    = "https://github.com/andycamp/orasaurus"
  s.summary     = %q{Tools for building Oracle Applications}
  s.description = %q{A simple toolset for making it easier to build Oracle databases.}

  s.rubyforge_project = "orasaurus"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.bindir        = 'bin'
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "thor"
  #s.add_runtime_dependency "ruby-oci8"
  #s.add_runtime_dependency "ruby-plsql"
end
