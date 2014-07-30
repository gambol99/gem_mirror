#!/usr/bin/env ruby
#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:14:05 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
require 'rubygems' if RUBY_VERSION '1.9.0'
require 'gem_mirror'

options = {
  :config => './config.yml'
}

gems = GemMirror.new options
puts "Number of gems: %d, total size: #{%d}" % [ gems.count, gems.size ]



