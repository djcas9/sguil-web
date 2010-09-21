#
# SguilWeb - A web client for the popular Sguil security analysis tool.
#
# Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

module Sguil
  module Helpers
    module UI
      
      #
      # Green
      #
      # @param [String] msg Message to format.
      #
      # @return [String] Green Colored String
      #
      def green(msg)
        "\e[32m#{msg}\e[0m"
      end

      #
      # Yellow
      #
      # @param [String] msg Message to format.
      #
      # @return [String] Yellow Colored String
      #
      def yellow(msg)
        "\e[33m#{msg}\e[0m"
      end
      
      #
      # Blue
      #
      # @param [String] msg Message to format.
      #
      # @return [String] Blue Colored String
      #
      def blue(msg)
        "\e[34m#{msg}\e[0m"
      end

      #
      # Red
      #
      # @param [String] msg Message to format.
      #
      # @return [String] Red Colored String
      #
      def red(msg)
        "\e[31m#{msg}\e[0m"
      end

      # Prompt the use for input
      #
      # @param [String] msg
      #  Message to prompt for user input.
      #
      # @param [Hash] options
      #
      # @option options [Symbol, String] :default
      #   The default option for a return.
      #
      def ask(msg, options={})
        default = options[:default] || false

        if default
          STDOUT.print "#{green("INFO")} #{msg} [Y/n] "
        else
          STDOUT.print "#{green("INFO")} #{msg} [y/N] "
        end
        input = STDIN.gets.chomp
        STDOUT.flush

        if block_given?
          if input[/([Yy]|[Yy]es)$/i]
            yield
          elsif input[/([Nn]|[Nn]o)$/i]
            return
          else
            yield if default
          end
        end
      end
      
    end
  end
end