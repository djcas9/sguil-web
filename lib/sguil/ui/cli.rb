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

require 'optparse'

module Sguil
  module UI
    class CLI
      include Sguil::Helpers::CLI

      def initialize(options={})
        @options = options
        Sguil.logger.setup([:debug,:verbose,:warn,:info])
      end

      def options(*args)

        @options = OpenStruct.new

        @opts = OptionParser.new do |opts|
          opts.banner = "SguilWeb - Version: #{Sguil::VERSION}.\nUsage: sguil-web -p 3000 -e production\n\n"

          opts.on('-a ','--add-user USERNAME', String, 'Add a new SguilWeb user.') do |username|
            @options.username = username
          end

          opts.on('-e ','--env ', [:development, :production], 'Set the SguilWeb Environment. Default: development') do |env|
            @options.env = env
          end

          opts.on('-p ','--port ', Integer, 'Set the SguilWeb Port. Default: 8080') do |port|
            @options.port = port
          end

          opts.on('-h', '--help', 'This help summary page.') do |help|
            print_usage
          end

          opts.on('-v', '--version', 'Version number') do |version|
            STDOUT.puts "SguilWeb - Version: #{Sguil::VERSION}"
            exit -1
          end
          
        end

        begin
          arguments = @opts.parse!(args)
          puts arguments
          print_usage if @options.empty?
        rescue Interrupt
          Sguil.logger.explicit "\nExiting..."
        rescue OptionParser::MissingArgument => e
          Sguil.logger.warning e.message
          STDOUT.puts @opts
          STDOUT.puts "\n"
          exit -1
        rescue OptionParser::InvalidOption => e
          Sguil.logger.warning e.message
          STDOUT.puts @opts
          STDOUT.puts "\n"
          exit -1
        end
      end

      def print_usage
        STDOUT.puts "#{@opts}\n"
        exit -1
      end

      def server
        Sguil::UI::Web.run!(options={})
      end

    end
  end
end
