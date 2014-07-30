#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:46:40 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
require 'utils'
require 'threads'
require 'timeout'
require 'tempfile'
require 'forwardable'

module GemMirror
  class Source
      extend Forwardable
    include GemMirror::Logging
    include HTTParty

    attr_accessor :name, :destination, :threads, :remove_deleted

    def_delegator :update_spec.size, :size
    def_delegator :update, :gems
    def_delegator :self.class.base_uri, :source

    def initialize name 
      @name = name
      @destination = nil
      @source = nil
      @threads = 1
      @source_specification = nil
      @remove_deleted = true
    end

    def source=(value)
      self.class.base_uri = @source 
    end

    def refresh
      @gems_spec = nil
      update
    end

    def mirror directory = @destination, &block 
      info "name: #{name}, starting off the mirroring on gems"


    end

    def update timeout = 30
      @source_specification ||= update_source_specification( timeout )
    end

    private
    def update_source_specification update_spec_timout = 30
      debug "update_spec: attempting the specification from the source: #{source}"
      # step: pull the gem specification file from the source
      specification = fetch.get( gems_source_spec, timeout )
      debug "update_spec: saved the gems_specification"
      # step: if the specification is gzip we save to a temporary file and uncompress

    end

    def fetch
      @fetch ||= GemMirror::Fetch.new settings[:source]
    end

    def temporary_file
      Tempfile.new( "#{name}_spec" )
    end

    def list_saved_gems
      Dir[destination('*.gems')].entries.map { |f| File.basename(f) }
    end

    def gems_source_spec
      "#{source}/#{Gem.marshal_version}}".gz
    end

    def destination filter = nil
      return settings[:dest] if filter.nil?
      settings[:dest] << '/' << filter
    end
  end
end

