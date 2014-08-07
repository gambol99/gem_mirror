#
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
require 'pp'

module GemMirror
  class Mirror
    include GemMirror::Utils::FileUtils
    include GemMirror::Utils::URLS
    include GemMirror::Utils::Logger

    def initialize options
      settings validate_options( options )
    end

    def mirrors 
      settings['mirrors'].keys
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

    def refresh name
      raise ArgumentError, "the mirror: #{name} has not been defined" unless mirror? name 
      PP.pp sources[name]
      sources[name].refresh
    end

    def mirror name
      raise ArgumentError, "the mirror: #{name} has not been defined" unless mirror? name 

    end

    private
    def settings configuration = nil
      @settings ||= configuration
    end

    def mirror? name 
      settings[name].nil?
    end

    def validate_options options 
      # step: load any configurations files
      configuration = ( options[:config] ) ? load_configuration_file( options[:config] ) : set_default_configuration
      # step: check we have the validate_options
      raise ArgumentError, "you have not specified any mirrors" unless configuration['mirrors']
      configuration['mirrors'].each_pair do |name,config|
        validate_mirror_configuration name, config
        new_source = GemMirror::Source.new name 
        new_source.source = config['source']
        new_source.destination = config['destination']
        new_source.threads = config['threads'] || configuration['threads'] || 1
        new_source.remove_deleted = config['remove_deleted'] || configuration['remove_deleted'] || true 
        sources[name] = new_source
      end
      PP.pp sources
      configuration
    end

    def sources 
      @sources ||= {}
    end

    def source? source
      uri? source
    end

    def set_default_configuration
      {}
    end 

    def load_configuration_file filename  
      validate_file filename
      YAML.load(File.read(filename))
    end

    def validate_mirror_configuration name, configuration
      raise ArgumentError, "you have not specified the name of the source" unless name
      raise ArgumentError, "#{name}: you have not specified the source url" unless configuration['source']
      raise ArgumentError, "#{name}: you have not specified the destination directory" unless configuration['destination']
      debug "checking mirror: #{name}, source: #{configuration['source']}, destination: #{configuration['destination']}"
      # step: check the source url is valid
      raise ArgumentError, "#{name}: the source: #{configuration['source']} is not a valid uri" unless uri? configuration['source']
      validate_directory configuration['destination'], true
    end

  end
end
