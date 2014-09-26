#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 16:52:37 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
require 'httparty'
require 'timeout'
require 'thread'

module GemMirror
  class Fetch
    include HTTParty
    include GemMirror::Utils::URLS
    include GemMirror::Utils::LoggerUtils

    Default_Timeout = 30

    def initialize base_uri
      raise ArgumentError, "the base url: #{base_uri} is invalid" unless uri? base_uri
      self.class.base_uri base_uri
    end

    def file url, filename, timeout = Default_Timeout
      debug "file: saving the file: #{url}, filename: #{filename}, timeout: #{timeout}"
      File.open( filename, 'w' ) do |fd|
        fd.binmode
        fd.write( get( url, timeout ).parsed_response )
      end
      debug "file: downloaded file: #{url}, filaname: #{filename}, size: #{File.size(filename)} bytes"
    end

    def files base_url, filelist = [], destination, threads
      debug "files: base_url: #{base_url}, filelist size: #{filelist.size}, destination: #{destination}, threads: #{threads}"
      # step: split the filelist into section
      file_sections = split filelist, threads
      scrappers = []
      file_sections.each do |list|
        next if list.empty?
        scrappers << Thread.new do
          debug "files: created thread, id: #{Thread.current.object_id}"
          list.each do |filename|
            debug "files: thread id: #{Thread.current.object_id} downloading file: #{filename}"
            begin
              file_source = "#{base_url}/downloads/#{filename}"
              file_dest   = "#{destination}/#{filename}"
              debug "files: downloading: #{file_source}"
              file file_source, file_dest
              yield Thread.current.object_id, filename, file_source, file_dest, true if block_given?
            rescue Exception => e
              debug "files: error: #{e.message}"
              yield Thread.current.object_id, filename, file_source, file_dest, false if block_given?
            end
          end
        end
      end
      # step: wait for the threads to finish
      scrappers.each(&:join)
    end

    def etag path, timeout = Default_Timeout
      head( path, timeout ).headers['ETag']
    end

    def get path, timeout = Default_Timeout
      request :get, path, timeout
    end

    def head path, timeout = Default_Timeout
      request :head, path, timeout
    end

    private
    def split list = [], groups = 1
      sections   = []
      group_size = ( list.size / groups ).ceil
      group_size = ( group_size == 0 ) ? groups : group_size
      index      = 0
      groups.times.each do
        if index > list.size
          sections << []
        else
          sections << list[index..(index+group_size)]
        end
        index += group_size
      end
      sections
    end

    def request method, path, timeout = Default_Timeout, options = {}
      response = nil
      begin
        raise ArgumentError, "the method: #{method} is not supported" unless self.class.respond_to? method
        Timeout::timeout( timeout ) do
          start_time = Time.now
          debug "request: method: #{method}, path: #{path}, timeout: #{timeout}"
          response = self.class.send method, path, options
          time_took = Time.now - start_time
          debug "request: response code: #{response.code}, time: #{time_took * 1000} ms"
        end
        handle_response_error response unless response.code == 200
      rescue Timeout::Error => e
        error "request: method: #{method}, path: #{path}, options: #{options} timed out"
        raise Exception, "request timed out waiting for response"
      end
      response
    end

    def handle_response_error response
      case response.code.to_i
      when 304
      when 302
        get response.headers['location'], path
      when 403, 404
        warn "#{resp.code} on #{File.basename(path)}"
      else
        raise Error, "unexpected response #{resp.inspect}"
      end
    end
  end
end


