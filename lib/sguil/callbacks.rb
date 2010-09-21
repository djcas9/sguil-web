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
  
  def Sguil.callbacks
    @callbacks ||= []
  end
  
  def Sguil.before_receive_data
    @before_data_callbacks ||= []
  end
  
  def Sguil.before_connect
    @connect_callbacks ||= []
  end
  
  def Sguil.before_disconnect
    @disconnect_callbacks ||= []
  end
  
  module Callbacks
    
    class << self
      include Sguil::Helpers::UI
    end
    
    def add_command(&block)
      Sguil.callbacks << block if block
    end
    
    def before_receive_data(&block)
      Sguil.before_receive_data << block if block
    end
    
    def before_connect(&block)
      Sguil.on_connect << block if block
    end
    
    def before_disconnect(&block)
      Sguil.on_disconnect << block if block
    end
    
  end
  
end