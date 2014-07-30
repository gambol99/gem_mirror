#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:46:40 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
require 'utils'
require 'httparty'
require 'threads'
require 'timeout'
require 'tempfile'

module GemMirror
  class Mirror
    include GemMirror::Logging
    include GemMirror::Utils::FileUtils
    include GemMirror::Utils::URLS
    include HTTParty

    def initialize mirror_configuration
      @settings = validate_mirror_configuration( mirror_configuration )
      self.class.base_uri = settings[:source]
    end

    def size
      update_spec.size
    end

    def refresh
      @gems_spec = nil
      update
    end

    def mirror
      info "name: #{name}, starting off the mirroring on gems"

    end

    def update
      @gems_spec ||= update_spec
    end
    alias_method :update, :gems

    private
    def validate_mirror_configuration config = {}
      # step: check we have the options
      raise ArgumentError, "you have not specified the name of the source" unless config[:name]
      raise ArgumentError, "you have not specified the source url" unless config[:source]
      raise ArgumentError, "you habe not specified the destination directory" unless config[:destination]
      debug "name: #{name}, source: #{source}, destination: #{destination}"
      # step: check the source url is valid
      raise ArgumentError, "the source: #{config[:source]} is not a valid uri" unless uri? config[:source]
      validate_directory config[:destination], true
      config
    end

    def update_spec update_spec_timout = 30
      debug "update_spec: attempting the specification from the source: #{source}"
      begin
        response = nil
        gems_specification = temporary_file
        Timeout.timeout update_spec_timout do
          debug "update_spec: downloading the specification from: #{gems_spec}"
          response = self.class.get( gems_spec )
        end
        debug "update_spec: writing out the gems specification for source: #{name} to temporary file: #{gems_specification}"
        File.open( gems_specification, "wb" ) do |fd|
          response.parsed_response do |io|
            fd.puts io
          end
        end
        debug "update_spec: saved the gems_specification"
      rescue Timeout::Error => e
        raise Exception, "timed out after #{update_spec_timout} seconds attempting pull #{gems_spec}"
      end
    end

    def timeout time_out = 30, &block
      Timeout.timeout time_out { yield }
    end

    def temporary_file
      Tempfile.new( "#{name}_spec" )
    end

    def list_saved_gems
      Dir[destination('*.gems')].entries.map { |f| File.basename(f) }
    end

    def settings
      @settings
    end

    def name
      settings[:name]
    end

    def source
      settings[:source]
    end

    def gems_specification
      settings[:spec]
    end

    def threads
      settings[:threads] || 10
    end

    def gems_spec
      "#{source}/#{Gem.marshal_version}}".gz
    end

    def temp

    def destination filter = nil
      return settings[:dest] if filter.nil?
      settings[:dest] << '/' << filter
    end
  end
end

