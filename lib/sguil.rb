require 'eventmachine'
require 'pp'

require 'sguil/helpers'
require 'sguil/ui'
require 'sguil/callbacks'
require 'sguil/connect'
require 'sguil/version'

module Sguil
  class << self
    include Sguil::Helpers::UI

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
