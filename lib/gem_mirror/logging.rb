#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-30 14:05:29 +0100 (Wed, 30 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
module GemMirror
  module Logger
    %w(info debug error warn).each do |x|
      define_method x.to_sym do |x,message|
        formated_print_line x, message
      end
    end

    private
    def formated_print_line prefix, message, color = :none
      puts "%-5s : %s" % [ "[#{prefix}]", message ] if message
    end
  end
end
