#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:46:40 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
require 'utils'
require 'thread'
require 'timeout'
require 'tempfile'
require 'fetch'
require 'forwardable'
require 'marshalled'

module GemMirror
  class Source
      extend Forwardable
    include GemMirror::Utils::Logger

    attr_accessor :name, :destination, :threads, :remove_deleted, :source

    def_delegator :update_spec.size, :size
    def_delegator :update, :gems

    def initialize name
      @name = name
      @destination = nil
      @source = nil
      @threads = 1
      @source_specification = nil
      @remove_deleted = true
    end

    def refresh
      update
    end

    def mirror directory = @destination, &block
      info "name: #{name}, starting off the mirroring on gems"
      # step: refresh the gems specification file
      refresh
      # step: load the marshalled data


    end

    def update timeout = 30
      debug "update: name: #{@name}, updating the specification"
      @source_specification ||= update_specification( timeout )
    end

    private
    def update_specification update_spec_timout = 30, gzip_file = true
      debug "update_spec: attempting the specification from the source: #{source}"
      # step: pull the gem specification file from the source
      source_specification = temporary_file
      source_specification.binmode
      fetch.file( gems_specification, source_specification, update_spec_timout )
      debug "update_spec: #{@name} saved the gems_specification, %s" % [ source_specification.path ]
      # step: if the specification is gzip we save to a temporary file and uncompress
      source_specification
    end

    def unmarshal filename = "#{name}_spec"

    end

    def fetch
      @fetch ||= GemMirror::Fetch.new source
    end

    def temporary_file
      Tempfile.new( "#{name}_spec" )
    end

    def list_saved_gems
      Dir[destination('*.gems')].entries.map { |f| File.basename(f) }
    end

    def gems_specification gzip = false
      ( gzip ) ? gems_specification_filename_gz : gems_specification_filename
    end

    def gems_specification_filename
      "#{source}/specs.#{Gem.marshal_version}"
    end

    def gems_specification_filename_gz
      gems_specification_filename << ".gz"
    end

    def destination filter = nil
      return settings[:dest] if filter.nil?
      settings[:dest] << '/' << filter
    end
  end
end

