require 'faye'
require 'json'
require 'sguil/parse'
require 'pp'

module Sguil
  module Connect
    include Sguil::Callbacks
    include Sguil::Helpers::Commands
    include Sguil::Helpers::UI

    @client_count = 0
    attr_accessor :client_count

    def post_init
      @buffer = ''
      sguil_connect
      send_data "ValidateUser demo demo"
    end

    # def ssl_handshake_completed
    #   puts get_peer_cert
    #   close_connection
    # end

    def unbind
      sguil_disconnect
    end

    def receive_data(data)
      puts data
      @buffer << data
      puts @buffer
      while line = @buffer #.slice!(/(.+)\r?\n/)

        @unknown_command = true
        puts line if @verbose

        Sguil.callbacks.each do |block|
          (block.call(self,line) && @unknown_command = false) if block
        end

        # case line
        # when %r|^NewSnortStats|
        #   format_and_publish(:new_snort_stats, data)
        # when %r|^UserMessage|
        #   format_and_publish(:user_message, data)
        # when %r|^InsertSystemInfoMsg|
        #   format_and_publish(:insert_system_information, data)
        # when %r|^UpdateSnortStats|
        #   format_and_publish(:update_snort_stats, data)
        # when %r|^InsertEvent|
        #   format_and_publish(:insert_event, data)
        # end

        #format_snort_stats(data) if data =~ /NewSnortStats/
        # format_user_message(data) if data =~ /UserMessage/
        # format_system_message(data) if data =~ /InsertSystemInfoMsg/
        # push('sensor', format_update_data(data)) if data =~ /UpdateSnortStats/ #/InsertEvent/

      end
    end
  end
end
