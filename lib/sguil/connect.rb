require 'faye'
require 'json'
require 'sguil/parse'
require 'pp'

module Sguil
  class Connect
    include Sguil::Callbacks
    include Sguil::Helpers::Commands
    include Sguil::Helpers::UI

    @client_count = 0
    attr_accessor :client_count, :server, :client, :port, :verbose, :socket

    def initialize(options={})
      @server = options[:server] || 'demo.sguil.net'
      @client = options[:client] || '0.0.0.0:3000'
      @port = options[:port] || 7734
      @verbose = options[:verbose] || true
      @socket = TCPSocket.open(@server, @port)
      Sguil.ui.info "SguilWeb #{Sguil::VERSION}\nConnecting to Sguil Server: #{@server}:#{@port}"
      sguil_connect
    end

    def login(options={})
      username = options[:username] || 'demo'
      password = options[:password] || 'demo'
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
      if sensors
        return send("MonitorSensors {#{sensors.join(' ')}}") if sensors.kind_of?(Array)
        send("MonitorSensors {#{sensors}}")
      end
    end

    def kill!
      @socket.close
      exit -1
    end

    def receive_data

      Sguil.before_receive_data.each { |block| block.call if block }

      while line = @socket.gets do

        @unknown_command = true
        puts line if @verbose

        Sguil.callbacks.each do |block|
          (block.call(self,line) && @unknown_command = false) if block
        end

        case line
        when %r|^NewSnortStats|
          push 'path_here', format_and_publish(:new_snort_stats, line)
        when %r|^SensorList|
          format_and_publish(:sensors, line)
        when %r|^UserMessage|
          push '/user/message', format_and_publish(:user_message, data)
        when %r|^InsertSystemInfoMsg|
          push '/system/message', format_and_publish(:insert_system_information, data)
        when %r|^UpdateSnortStats|
          push '/sensor/updates', format_and_publish(:update_snort_stats, data)
        when %r|^InsertEvent|
          format_and_publish(:insert_event, data)
        end
      end
    end


  end
end
