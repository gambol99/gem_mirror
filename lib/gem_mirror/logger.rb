#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-09-18 12:17:22 +0100 (Thu, 18 Sep 2014)
#
#  vim:ts=4:sw=4:et
#
module GemMirror
  class Logger
    class << self
      attr_accessor :loglevel

      def init loglevel
        self.loglevel = loglevel
      end

      def method_missing( m,*args,&block)
        return if m == :debug and self.loglevel != :debug
        puts "[%s]%-7s : %s" % [ Time.now, "[#{m.to_sym}]", args.first ]
      end
    end
  end
end
