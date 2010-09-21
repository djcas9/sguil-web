#
# Sguil[web] - A web client for the popular Sguil security analysis tool.
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
  module UI
    class Logger
      include Sguil::Helpers::UI

      LOGGERS = [:DEBUG, :VERBOSE, :INFO, :WARN, :ERROR]

      def setup(loggers)
        loggers.each do |log|
          const_name = "#{log}".upcase

          if Sguil::UI::LOGGERS.include?(const_name.to_sym)
            Sguil::UI.const_set(const_name.to_sym, true)
          else
            Sguil.ui.error("Unknown Logger #{const_name}\nAvailable Logger Options: #{Sguil::UI::LOGGERS.inspect}")
          end

        end
      end

      def info(message)
        show_message :INFO, "#{message}", STDOUT if configured(:INFO)
      end

      def verbose(message)
        show_message :VERBOSE, "#{message}", STDOUT if configured(:VERBOSE)
      end

      def debug(message)
        show_message :DEBUG, "#{message}", STDOUT if configured(:DEBUG)
      end

      def warning(message)
        show_message :WARN, "#{message}", STDOUT if configured(:WARN)
      end

      def error(message)
        show_message :ERROR, "#{message}", STDERR
      end

      def explicit(msg)
        STDOUT.puts red("#{msg}")
      end

      def configured(const)
        if Sguil::UI.const_defined?(const)
          return Sguil::UI.const_get(const)
        else
          return false
        end
      end

      def show_message(type,message,std)
        case type
        when :INFO
          type = green(type)
        when :WARN
          type = yellow(type)
        when :ERROR
          type = red(type)
        when :DEBUG
          type = green(type)
        when :VERBOSE
          type = blue(type)
        end

        message.split("\n").each do |msg|
          std.puts("#{type}: #{msg}") if std.respond_to?(:puts)
        end

      end

    end
  end
end
