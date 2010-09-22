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

require 'rest-client'

module Sguil
  module Helpers
    module Commands
      
      def self.included(klass)
        klass.extend self
      end

      def sguil_setup
        Sguil.before_connect.each { |block| block.call if block }
        Sguil.logger.info "Client: Connected. (#{@uid})"
      end

      def sguil_disconnect
        Sguil.before_disconnect.each { |block| block.call if block }
        Sguil.logger.warning "Logout: #{@username} (#{@uid})"
      end

      def format_and_publish(method,data)
        parser = Parse.new(data)
        parser.send(method.to_sym) if parser.respond_to?(method.to_sym)
      end

      def send(data)
        @socket.puts(data)
      end

      def push(path, data)
        begin
          
          data.merge!({:uid => @uid}) if data.is_a?(Hash)
          RestClient.post("http://#{@client}/#{path}", data)
          
          Sguil.logger.debug("PATH: http://#{@client}/#{path}\nPARAMS: #{data.inspect}")
          
        rescue => error_message
          Sguil.logger.error "Error: #{error_message}"
        end
      end

    end
  end
end
