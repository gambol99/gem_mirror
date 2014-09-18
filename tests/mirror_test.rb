#!/usr/bin/env ruby
#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:14:05 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','../lib')
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'gem_mirror'

options = {
  :config   => './config.yml',
  :loglevel => :info
}

gems = GemMirror.new options

#gems.mirror 'rubygems', '^optionscrapper'
gems.check_updates 'rubygems', '^option'

gems.mirror 'rubygems', '^option'
#puts "mirror: #{source.name}, gems: #{source.size}"
#puts "mirroring the source now"
#source.mirror '/var/rubygem'




