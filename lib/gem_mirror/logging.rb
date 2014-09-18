#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:05:29 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
module GemMirror
  module Utils
    module LoggerUtils
      [:debug, :info,:error,:warn].each do |m|
        define_method m do |*args,&block|
          GemMirror::Logger.send m, args.first, &block
          #formated_print_line m.to_s, args.first || ''
        end
      end

      private
      def formated_print_line prefix, message, color = :none
        GemMirror::Logger.send  "[%s]%-7s : %s" % [ Time.now, "[#{prefix}]", message ] if message
      end
    end
  end
end
