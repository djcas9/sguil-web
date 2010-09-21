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

require 'faye'
require 'json'
require 'sguil/parse'

module Sguil
  class Connect
    include Sguil::Callbacks
    include Sguil::Helpers::Commands
    include Sguil::Helpers::UI
    # extend Forwardable

    @client_count = 0
    @user_id = ''
    
    attr_accessor :client_count, :server, :client, :port, :socket, :username, :user_id
    # def_delegators :client, :publish, :subscribe

    def initialize(options={})
      @server = options[:server] || 'demo.sguil.net'
      @client = options[:client] || '0.0.0.0:3000'
      @port = options[:port] || 7734
      @uid = options[:uid]
      
      Sguil.logger.setup(options[:logger] || [])
      
      @socket = TCPSocket.open(@server, @port)
      Sguil.logger.info "SguilWeb #{Sguil::VERSION}\nConnecting to Sguil Server: #{@server}:#{@port}"
      sguil_connect
    end

    # def client
    #   ensure_em_running!
    #   @client ||= Faye::Client.new("http://#{@client}/sguil")
    # end
    # 
    # def ensure_em_running!
    #   Thread.new { EM.run } unless EM.reactor_running?
    #   while not EM.reactor_running?
    #   end
    # end

    def login(options={})
      username = options[:username] || 'demo'
      password = options[:password] || 'demo'
      @username = username
      
      Sguil.logger.info "New Login - #{username}"
      send("ValidateUser #{username} #{password}")
    end

    def sensors
      Sguil.sensors
    end

    def send_message(message)
      send("UserMessage {#{message.strip}}")
    end

    def sensor_list
      send("SendSensorList")
    end

    def monitor(sensors)
      Sguil.logger.info "Connecting to sensors - #{sensors}"
      if sensors
        return send("MonitorSensors {#{sensors.join(' ')}}") if sensors.kind_of?(Array)
        send("MonitorSensors {#{sensors}}")
      end
    end

    def kill!
      Sguil.logger.info "Killing Connection - #{@uid}"
      @socket.close
      exit -1
    end

    def receive_data

      Sguil.before_receive_data.each { |block| block.call if block }

      while line = @socket.gets do

        Sguil.logger.verbose(line)
        
        #Sguil.callbacks.each { |block| block.call(self,line) if block }

        case line
        when %r|^NewSnortStats|
          push 'sensor/updates', format_and_publish(:new_snort_stats, line)
        when %r|^SensorList|
          format_and_publish(:sensors, line)
        when %r|^UserMessage|
          push 'user/message', format_and_publish(:user_message, line)
        when %r|^InsertSystemInfoMsg|
          push 'system/message', format_and_publish(:insert_system_information, line)
        when %r|^UpdateSnortStats|
          push 'sensor/updates', format_and_publish(:update_snort_stats, line)
        when %r|^InsertEvent|
          push 'insert/events', format_and_publish(:insert_event, line)
        when %r|^IncrEvent|
          push 'increment/event', format_and_publish(:increment_event, line)
        when %r|^UserID|
          @user_id ||= line.gsub('UserID', '').to_i
        end
      end
    end


  end
end
