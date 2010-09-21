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
  module Plugins
    module Sinatra
      
      module ContentFor

        def content_for(key, &block)
          content_blocks[key.to_sym] << block
        end

        def yield_content(key, *args)
          content_blocks[key.to_sym].map do |content|
            if respond_to?(:block_is_haml?) && block_is_haml?(content)
              capture_haml(*args, &content)
            else
              content.call(*args)
            end
          end.join
        end

        private

          def content_blocks
            @content_blocks ||= Hash.new {|h,k| h[k] = [] }
          end
      end

      helpers ContentFor
    end
  end
end
