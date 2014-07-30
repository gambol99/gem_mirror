#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 13:52:46 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
module GemMirror
  ROOT = File.expand_path File.dirname __FILE__

  autoload :Mirror, "#{ROOT}/gem_mirror/mirror"

  def self.version
    VERSION = '0.0.1'
  end

  def self.new options
    GemMirror::Mirror.new options
  end
end
