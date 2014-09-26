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
        end
      end
    end
  end
end
