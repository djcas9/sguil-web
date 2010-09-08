module Sguil
  module Helpers
    module Commands
      include Sguil::Helpers::UI
      
      def sguil_connect
        Sguil.ui.info "Client Connected."
        Sguil.on_connect.each { |block| block.call if block }
      end
      
      def sguil_disconnect
        Sguil.ui.warning "Client Disconnected."
        Sguil.on_disconnect.each { |block| block.call if block }
        close_connection_after_writing
      end
      
      def format_and_publish(method,data)
        parser = Parse.new(data)
        parser.send(method.to_sym) if parser.respond_to?(method.to_sym)
      end
      
      def login
        
      end
      
    end
  end
end