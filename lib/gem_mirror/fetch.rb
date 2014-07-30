#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 16:52:37 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
require 'httparty'
require 'timeout'

module GemMirror
  class Fetch
    include HTTParty
    include GemMirror::Utils::URLS
    include GemMirror::Logging

    Default_Timeout = 30

    def initialize base_uri
      raise ArgumentError, "the base url: #{base_uri} is invalid" unless uri? base_uri
      self.class.base_uri = base_uri
    end

    def file path, save_to, timeout = Default_Timeout
      response = get( path, timeout )
    end

    def get path, timeout = Default_Timeout
      begin
        Timeout::timeout timeout do
          response = self.class.get path
          handle_error response.code
        end
      rescue Timeout::Error => e

      end
    end

    private
    def handle_error http_code
      case resp.code.to_i
      when 304
      when 302
        get resp['location'], path
      when 403, 404
        warn "#{resp.code} on #{File.basename(path)}"
      else
        raise Error, "unexpected response #{resp.inspect}"
      end
    end
  end
end


