$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'

require 'sguil'
include Sguil::Callbacks

@sguil = Sguil.connect({:client => '0.0.0.0', :verbose => true})

before_receive_data do 
  @sguil.login('demo', 'demo')
  @sguil.sensor_list
  puts @sguil.sensors
  @sguil.monitor(@sguil.sensors)
end

@sguil.receive_data

