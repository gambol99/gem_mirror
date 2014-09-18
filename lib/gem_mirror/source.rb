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
require 'digest'
require 'pp'

module GemMirror
  class Source
    include GemMirror::Utils::Logger

    attr_accessor :name, :destination, :threads, :remove_deleted, :source

    def initialize name
      @name = name
      @destination = nil
      @source = nil
      @threads = 1
      @source_specification = nil
      @remove_deleted = true
      @gems_specification_data = nil
    end

    def refresh timeout = 30
      debug "refresh: name: #{@name}, timeout: #{timeout}, updating the specification"
      update_gems_specification timeout
      debug "refresh: successfully refreshed the gems specification, size: #{gems.size}"
    end

    def mirror filter
      info "name: #{name}, starting off the mirroring on gems"
      # step: refresh the gems specification file and reload the gems data if need be
      update_gems_specification
      # step: get a list all the gems we are missing
      gems_missing = gems_available_from_source( filter ) - gems_present
      debug "mirror: we have #{gems_missing.size} missing"
    end

    private
    def update_gems_specification timeout = 30
      debug "update_specification: checking we have a gem specification already"
      if gems_specification?
        # step: we have one already, lets check if it's been updated
        etag = fetch.etag gems_specification_url || nil
        if etag.nil?
          warn "update_gems_specification: unable to get the etag for specification file on #{gems_specification_url}"
          download_gems_specification timeout
        else
          debug "update_gems_specification: computing the md5sum of spec file: #{gems_specification_file}"
          # step: compute the digest of our gems specification file
          digest = Digest::MD5.file( gems_specification_file ).to_s
          debug "update_gems_specification: digest: #{digest}, etag: #{etag}"
          if !digest =~ /^#{etag}$/
            debug "update_gems_specification: specification file: #{gems_specification_file} needs updating"
            download_gems_specification timeout
          else
            debug "update_gems_specification: specification file: #{gems_specification_file} already up to date"
          end
        end
      else
        download_gems_specification timeout
      end
    end

    def download_gems_specification timeout = 30
      debug "download_gems_specification: source: #{name}, specifications file does not exist, downloading now to: #{gems_specification_file}"
      fetch.file gems_specification_url, gems_specification_file, timeout
      debug "download_gems_specification: succesfully downloaded the specification file to: #{gems_specification_file}"
      debug "download_gems_specification: reloading the gems data from specification file"
      load_gems_specification
    end

    def load_gems_specification
      debug "load_gems_specification: loading the specification"
      start_time = Time.now
      @gems_specification_data = Marshal.load( Zlib::GzipReader.new( File.open( gems_specification_file ) ).read )
      time_processed = Time.now - start_time
      debug "load_gems_specification: processing time: #{time_processed * 1000}ms"
    end

    def gems
      load_gems_specification unless @gems_specification_data
      @gems_specification_data
    end

    def gems_available_from_source filter
      start_time = Time.now
      data = gems.map { |name,version,type|
        name if type == 'ruby' and name[/#{filter}/]
      }.compact

      #data = gems.select { |name,version,type|
      #  type == 'ruby' and name =~ /#{filter}/
      #}.collect { |name,version,type|
      #  name
      #}
      time_took = Time.now - start_time
      debug "gems_available_from_source: time: #{time_took * 1000}ms"
      data
    end

    def gems_present
      Dir["#{@destination}/*.gems"].entries.map { |f| File.basename(f) }
    end

    def gems_specification?
      File.exists? gems_specification_file
    end

    def gems_specification_file
      "#{@destination}/#{gems_specification}"
    end

    def gems_specification
      "specs.#{Gem.marshal_version}.gz"
    end

    def gems_specification_url
      "#{@source}/#{gems_specification}"
    end

    def fetch
      @fetch ||= GemMirror::Fetch.new source
    end

    def list_saved_gems

    end
  end
end

