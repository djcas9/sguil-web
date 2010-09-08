require 'eventmachine'

require 'sguil/helpers'
require 'sguil/ui'
require 'sguil/callbacks'
require 'sguil/connect'
require 'sguil/version'

module Sguil
  class << self
    include Sguil::Helpers::UI

    def ui
      @ui ||= Sguil::UI.new
    end
    
    def connect(options={})
      @server = options[:server] || 'demo.sguil.net'
      @port = options[:port] || 7734
      @ssl = options[:ssl] || true
      @verbose = options[:verbose] || true

      begin
        Sguil.ui.info "SguilWeb #{Sguil::VERSION} - Connecting To Sguil Server #{@server}:#{@port}."
        EM.run do
          EventMachine::connect(@server, @port, Sguil::Connect)
        end
      rescue Interrupt
        Sguil.ui.explicit "Shutting Down...\n"
      end

    end
    
  end
end
