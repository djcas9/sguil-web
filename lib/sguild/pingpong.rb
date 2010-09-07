require 'forwardable'
require 'eventmachine'
require 'faye'

module Sguil
  
  HOST = 'http://0.0.0.0:3000/faye'

  class << self
    extend Forwardable
    def_delegators :client, :publish, :subscribe

    def client
      ensure_em_running!
      @client ||= Faye::Client.new(HOST)
    end

    def ensure_em_running!
      Thread.new { EM.run } unless EM.reactor_running?
      while not EM.reactor_running?
      end
    end
  end
  
end
