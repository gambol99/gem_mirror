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

module GemMirror
  class Source
    include GemMirror::Utils::LoggerUtils

    attr_accessor :name, :destination, :threads, :remove_deleted, :source, :filter

    def initialize name
      @name = name
      @destination = nil
      @source = nil
      @threads = 1
      @source_specification = nil
      @remove_deleted = true
      @gems_specification_data = nil
      @filter = '.*'
    end

    def refresh overrides
      debug "refresh: name: #{name}, timeout: #{timeout}, updating the specification"
      update_gems_specification overrides[:refresh_specification]
      debug "refresh: name: #{name}, successfully refreshed the gems specification, size: #{gems.size}"
    end

    def check_updates overrides
      info "check_updates: filter: #{filter}, checking for any gem file updates"
      # step: get an up to date gem specification
      update_gems_specification overrides[:refresh_specification]
      # step: found any missing gems
      ( gems_available_from_source( filter ) - gems_present || [] ).each do |x|
        info "check_updates: #{name}, we are missing: #{x}"
      end
    end

    def list overrides, &block
      # step: get a list of the available
      overrides[:filter] ||= '.*'
      # step: make sure we have a spec file and if requested, is up to date
      update_gems_specification overrides[:refresh_specification]
      # step: filter out the gems
      gems_available( overrides[:filter] ).each do |gem_package|
        yield gem_package if gem_package =~ /#{overrides[:filter]}/
      end
    end

    def mirror overrides
      info "mirror: #{name}, starting off the mirroring gems"
      # step: refresh the gems specification file and reload the gems data if need be
      info "mirror: checking if the gem specification is up to date"
      update_gems_specification overrides[:refresh_specification]
      # step: get a list all the gems we are missing
      gems_missing = gems_available( source_settings(:filter,overrides) ) - gems_present
      if gems_missing.empty?
        info "mirror: #{name}, we have no missing gems at present"
      else
        debug "mirror: #{name}, we have #{gems_missing.size} missing from destination: #{destination}"
        # step: start downloading the missing gems
        debug "mirror: #{name}, starting to download the missing gems to: #{destination}"
        fetch.files source, gems_missing, destination, threads do |id,filename,file_source,file_destination,result|
          info  "mirror: (#{id}) #{name}, downloaded gem: #{file_source}, destination: #{file_destination}" if result
          error "mirror: (#{id}) #{name}, error downloading gem: #{filename}" unless result
        end
        # step: delete any gems no longer in the source
        deletion_list = gems_for_deletion if source_settings(:delete_removed,overrides)
        if source_settings(:delete_removed, overrides) and !deletion_list.empty?
          info "mirror: #{name} deleting #{deletion_list.size} gems no longer in source"
          deletion_list.each do |filename|
            info "mirror: #{name} removing gem: #{filename} from mirror"
            File.delete gem_filename filename
          end
        end
      end
    end

    private
    def update_gems_specification refresh_specification = true, timeout = 30
      # step: if not set, we set true - which is possible given how we pass it
      refresh_specification ||= true
      # step: we can move on, if the file already exists and refresh_specification == false
      return if gems_specification? and !refresh_specification
      # step: check the specification is up to date
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
        debug "update_specification: no specification file found, downloading one now"
        download_gems_specification timeout
      end
    end

    def source_settings key, override
      if override.has_key? key
        override[key]
      else
        ( self.respond_to? key.to_sym ) ? self.send( key ) : nil
      end
    end

    def download_gems_specification timeout = 30
      debug "download_gems_specification: source: #{name}, specifications file does not exist, downloading now to: #{gems_specification_file}"
      fetch.file gems_specification_url, gems_specification_file, timeout
      debug "download_gems_specification: succesfully downloaded the specification file to: #{gems_specification_file}"
      debug "download_gems_specification: reloading the gems data from specification file"
      load_gems_specification
    end

    def gem_filename filename
      "#{destination}/#{filename}"
    end

    def load_gems_specification
      debug "load_gems_specification: loading the specification: #{gems_specification_file}"
      start_time = Time.now
      @gems_specification_data = Marshal.load( Zlib::GzipReader.new( File.open( gems_specification_file ) ).read )
      time_processed = Time.now - start_time
      debug "load_gems_specification: processing time: #{time_processed * 1000}ms"
      @gems_specification_data
    end

    def gems
      @gems_specification_data ||= load_gems_specification
    end

    def gems_available filter
      debug "gems_available: filter: #{filter}, gems: #{gems.size}"
      start_time = Time.now
      data = gems.map { |name,version,type|
        "#{name}-#{version}.gem" if type == 'ruby' and name[/#{filter}/]
      }.compact
      time_took = Time.now - start_time
      debug "gems_available: time: #{time_took * 1000}ms"
      data
    end

    def gems_for_deletion source, destination
      gems_present - gems_available
    end

    def gems_present
      Dir["#{destination}/*.gem"].entries.map { |f| File.basename(f) }
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
  end
end

