require 'faye'
require 'json'
require 'sguil/parse'
require 'pp'

module Sguil

  def Sguil.sensors
    @sensors ||= []
  end

  class Connect
    include Sguil::Callbacks
    include Sguil::Helpers::Commands
    include Sguil::Helpers::UI

    @client_count = 0
    @sensors = []
    attr_accessor :client_count, :server, :client, :port, :verbose, :socket, :sensors

    def initialize(options={})
      @server = options[:server] || 'demo.sguil.net'
      @client = options[:client] || '0.0.0.0:3000'
      @port = options[:port] || 7734
      @verbose = options[:verbose] || true
      @socket = TCPSocket.open(@server, @port)
      Sguil.ui.info "SguilWeb #{Sguil::VERSION} - Connecting To Sguil Server #{@server}:#{@port}."
      sguil_connect
    end

    def login(username,password)
      send "ValidateUser demo demo"
    end

    def send_message(message)
      send "UserMessage {#{message.strip}}"
      @socket.puts("UserMessage {#{msg.strip}}")
    end

    def sensor_list
      send "SendSensorList"
    end

    def monitor(sensors)
      if sensors.is_a?(Array)
        @socket.puts "MonitorSensors {#{sensors.join(' ')}}" if sensors
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
            format_and_publish(:new_snort_stats, line)
          when %r|^SensorList|
            Sguil.sensors << format_and_publish(:sensors, line)
            pp Sguil.sensors
            # when %r|^UserMessage|
            #   format_and_publish(:user_message, data)
            # when %r|^InsertSystemInfoMsg|
            #   format_and_publish(:insert_system_information, data)
            # when %r|^UpdateSnortStats|
            #   format_and_publish(:update_snort_stats, data)
            # when %r|^InsertEvent|
            #   format_and_publish(:insert_event, data)
          end

          # format_snort_stats(data) if data =~ /NewSnortStats/
          # format_user_message(data) if data =~ /UserMessage/
          # format_system_message(data) if data =~ /InsertSystemInfoMsg/
          # push('sensor', format_update_data(data)) if data =~ /UpdateSnortStats/ #/InsertEvent/
        end
      end
    end
  end
