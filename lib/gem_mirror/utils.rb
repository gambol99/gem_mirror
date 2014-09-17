#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:05:32 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
require 'gzip'

module GemMirror
  module Utils
    include GemMirror::Utils::Gzip
    module FileUtils
      def validate_file filename, writable = false
        raise ArgumentError, 'you have not specified a file to check'       unless filename
        raise ArgumentError, 'the file %s does not exist'   % [ filename ]  unless File.exists? filename
        raise ArgumentError, 'the file %s is not a file'    % [ filename ]  unless File.file? filename
        raise ArgumentError, 'the file %s is not readable'  % [ filename ]  unless File.readable? filename
        if writable
          raise ArgumentError, "the filename #{filename} is not writable"   unless File.writable? filename
        end
        filename
      end

      def validate_directory directory, writable = false
        raise ArgumentError, 'you have not specified a directory to check'  unless directory
        raise ArgumentError, 'the directory %s does not exist'   % [ directory ]  unless File.exists? directory
        raise ArgumentError, 'the directory %s is not a file'    % [ directory ]  unless File.directory? directory
        raise ArgumentError, 'the directory %s is not readable'  % [ directory ]  unless File.readable? directory
        if writable
          raise ArgumentError, "the filename #{directory} is not writable"   unless File.writable? directory
        end
        directory
      end
    end

    module URLS
      require 'uri' unless defined? URI
      def uri? url
        url =~ URI::regexp
      end
    end
  end
end
