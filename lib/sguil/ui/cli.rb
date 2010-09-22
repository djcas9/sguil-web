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

      def add_new_user
        
      end
      
      def options(*args)

        @options = {
          :bind => '0.0.0.0',
          :port => 3000,
          :environment => :development
        }

        @opts = OptionParser.new do |opts|
          opts.banner = "SguilWeb - Version: #{Sguil::VERSION}.\nUsage: sguil-web -s -h 0.0.0.0 -p 3000 -e production\n\n"

          opts.on('-s','--start', 'Start the SguilWeb server.') do |run|
            @options[:start] = true
          end

          opts.on('-e ','--env ', [:development, :production], 'Set The Environment. Default: development') do |environment|
            @options[:environment] = environment
          end
          
          opts.on('-h ','--host ', String, 'Set The Server Host. Default: 0.0.0.0') do |bind|
            @options[:bind] = bind
          end

          opts.on('-p ','--port ', Integer, 'Set The Server Port. Default: 8080') do |port|
            @options[:port] = port
          end
          
          opts.on('-a ','--add-user NAME', String, 'Add A New User.') do |username|
            @options[:db] = true
            add_new_user
          end
          
          opts.on('-r ','--remove-user NAME', String, 'Remove A User.') do |username|
            @options[:db] = true
            add_new_user
          end

          opts.on('-H', '--help', 'SguilWeb Usage & Information.') do |help|
            print_usage
          end

          opts.on('-v', '--version', 'Version Information') do |version|
            STDOUT.puts "SguilWeb - Version: #{Sguil::VERSION}"
            exit -1
          end

        end

        begin
          
          @args = @opts.parse!(args)
          start_server if @options[:start]
          print_usage unless @options[:start] || @options[:db]
          
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

      def start_server
        Sguil.server = "#{@options[:host]}:#{@options[:port]}"
        Sguil::UI::Web.run!(@options)
      end

    end
  end
end
