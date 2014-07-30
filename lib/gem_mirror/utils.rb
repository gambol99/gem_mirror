#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:05:32 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
module GemMirror
  module Utils
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
  end
end
