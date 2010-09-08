require 'rest-client'

module Sguil
  module Helpers
    module Commands
      include Sguil::Helpers::UI
      
      def sguil_connect
        Sguil.before_connect.each { |block| block.call if block }
        Sguil.ui.info "Client Connected."
      end
      
      def sguil_disconnect
        Sguil.before_disconnect.each { |block| block.call if block }
        Sguil.ui.warning "Client Disconnected."
        @socket.close
      end
      
      def format_and_publish(method,data)
        parser = Parse.new(data)
        parser.send(method.to_sym) if parser.respond_to?(method.to_sym)
      end
      
      def send(data)
        @socket.puts(data)
      end
      
      def push(path, data)
        RestClient.post("http://#{@client}/#{path}", data)
      end
      
    end
  end
end