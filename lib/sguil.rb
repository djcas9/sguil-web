require 'eventmachine'
require 'pp'

require 'sguil/helpers'
require 'sguil/ui'
require 'sguil/callbacks'
require 'sguil/connect'
require 'sguil/version'

module Sguil
  
  HOST = 'http://0.0.0.0:3000/sguil'
  
  class << self
    include Sguil::Helpers::UI
    extend Forwardable
    attr_accessor :clients
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

    def kill(client_id)
      Sguil.clients[client_id.to_sym][:fork].kill! if Sguil.clients.has_key?(client_id.to_sym)
    end

    def sensors
      @sensors ||= []
    end

    def sensors=(sensors)
      @sensors = sensors
    end

    def ui
      @ui ||= Sguil::UI.new
    end

    def connect(options={})
      Sguil::Connect.new(options)
    end

  end
end
