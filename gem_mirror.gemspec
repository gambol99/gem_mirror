#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:08:55 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','lib/gem-mirror' )
require 'version'

Gem::Specification.new do |s|
  s.name        = "gem-mirror"
  s.version     = GemMirror::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = '2014-07-31'
  s.authors     = ["Rohith Jayawardene"]
  s.email       = 'gambol99@gmail.com'
  s.homepage    = 'http://rubygems.org/gems/gem-mirror'
  s.summary     = %q{Gems mirroring libary}
  s.description = %q{A small libary for mirroring gems from one site to a directory}
  s.license     = 'GPL'
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
