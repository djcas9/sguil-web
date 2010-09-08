require 'eventmachine'
require 'faye'
require 'json'

require 'sguild/helpers'
require 'sguild/callbacks'
require 'sguild/parser'
require 'sguild/connect'
require 'sguild/version'

module Sguild
  class << self
    include Sguil::Helpers::UI

    def ui
      @ui ||= UI.new
    end
    
    def connect(options={},verbose=false)
      @server = options[:server] || '0.0.0.0'
      @port = options[:port] || 1221
      @ssl = options[:ssl] || true
      @verbose = verbose

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
