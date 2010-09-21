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
    module FileSystem
      
      #
      # Basename
      #
      # @param [String] path Path to extract the basename from
      #
      # @return [Object] Pathname Object
      #
      def basename(path)
        Pathname.new(path).basename
      end

      #
      # Parent Name
      #
      # @param [String] path Path to extract the parent folder name from
      #
      # @return [String] Parent Folder Name
      #
      def parent(path)
        Pathname.new(path).parent
      end

      #
      # Empty Folder?
      #
      # @param [String] folder Path to folder
      #
      # @return [true,false] Return true if the folder is empty.
      #
      def folder_empty?(folder)
        if File.exists?(folder)
          return true unless Dir.enum_for(:foreach, folder).any? {|n| /\A\.\.?\z/ !~ n}
          return false
        else
          return false
        end
      end
      
    end
  end
end