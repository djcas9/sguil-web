$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'sguil'

include Sguil::Callbacks

@sguil = Sguil.connect({:client => '0.0.0.0:3000', :verbose => true})

before_receive_data do 
  @sguil.login(:username => 'demo', :password => 'demo')
  @sguil.sensor_list
  puts @sguil.sensors
  puts Sguil.sensors
  @sguil.monitor('DEMO_DMZ')
  puts Sguil.sensors
end

@sguil.receive_data

