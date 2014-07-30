#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:46:40 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
require 'utils'
require 'httparty'
require 'threads'

module GemMirror
  class Mirror
    include GemMirror::Logging
    include GemMirror::Utils
    include HTTParty

    def initialize options
      @options = options

    end

    def size
      update_spec.size
    end

    def refresh_spec
      @gems_spec = nil
      update
    end

    def update
      @gems_spec ||= update_spec
    end
    alias_method :update, :gems

    protected
    def update_spec
      # pull the spec file from the source

    end

    def options
      @options
    end

    def destination
      options[:dest]
    end

    def source
      options[:source]
    end

    def threads
      options[:threads] || 10
    end
  end
end

