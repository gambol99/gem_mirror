#
#   Author: Rohith
#   Date: 2014-07-30 21:49:00 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','./')
require 'utils'
require 'yaml'
require 'logging'
require 'source'
require 'configuration'
require 'logger'

module GemMirror
  class Mirror
    include GemMirror::Utils::FileUtils
    include GemMirror::Utils::URLS
    include GemMirror::Utils::LoggerUtils
    include GemMirror::Configuration

    def initialize options
      settings validate_options( options )
      GemMirror::Logger.init options[:loglevel] || :info
    end

    def add name, source, directory = nil, options = {}
      raise ArgumentError, "you have not specified a name for the source" unless name
      raise ArgumentError, "the source: #{source} is not a valid url, please check" unless source? source
      source =  GemMirror::Source.new name
      source.source = source
      source.destination = destination
      options.each_pair do |k,v|
        source.send "#{k.to_sym}=", v  if source.respond_to? k.to_sym
      end
    end

    %w(:check_updates refresh mirror).each do |x|
      define_method x.to_sym do |name,overrides|
        raise ArgumentError, "the mirror: #{name} has not been defined" unless mirror? name
        overrides          ||= {}
        overrides[:filter] ||= '.*'
        overrides[:refresh_specification] ||= true
        sources[name].send( x.to_sym, overrides )
      end
    end

    def mirrors
      settings['mirrors'].keys
    end

    private
    def mirror? name
      settings[name].nil?
    end

    def sources
      @sources ||= {}
    end

    def source? source
      uri? source
    end
  end
end
