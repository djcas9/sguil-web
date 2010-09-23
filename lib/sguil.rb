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

require 'sguil/helpers'
require 'sguil/ui'
require 'sguil/callbacks'
require 'sguil/database'
require 'sguil/connect'
require 'sguil/version'

module Sguil
  include Sguil::Callbacks

  class << self
    include Sguil::Helpers::CLI
    attr_accessor :client, :clients, :server

    def client
      ensure_em_running!
      @client ||= Faye::Client.new("http://#{Sguil.server}/sguil", {:timeout => 45})
    end

    def ensure_em_running!
      Thread.new { EM.run } unless EM.reactor_running?
      while not EM.reactor_running?
      end
    end

    def clients
      @clients ||= {}
    end

    def add_client(name,socket)
      Sguil.clients.merge!({name.to_sym => {
                              :socket => socket
      }})
    end

    def add_fork(name,fork)
      Sguil.clients[name.to_sym].merge!({:fork => fork}) if Sguil.clients.has_key?(name.to_sym)
    end

    def has(client_id)
      return Sguil.clients.has_key?(client_id.to_sym) if client_id
      false
    end

    def fork(client_id)
      Sguil.clients[client_id.to_sym][:fork] if Sguil.clients.has_key?(client_id.to_sym)
    end

    def get(client_id)
      Sguil.clients[client_id.to_sym][:socket] if Sguil.clients.has_key?(client_id.to_sym)
    end

    def kill_all!
      Sguil.clients.each do |key,value|
        value[:fork].kill!
      end
    end

    def uid
      "client_#{Time.now.to_i}#{Time.now.usec}"
    end

    def logout(user)
      if user
        id = user.uid.to_sym
        Sguil.clients.delete(id) if Sguil.clients.has_key?(id)
        user.kill
      end
    end

    def sensors
      @sensors ||= []
    end

    def sensors=(sensors)
      @sensors = sensors
    end

    def logger
      @logger ||= Sguil::UI::Logger.new
    end

    def cli
      @cli = Sguil::UI::CLI.new
      @cli.options(*ARGV)
    end

    def connect(options={})
      Sguil::Connect.new(options)
    end

  end
end
