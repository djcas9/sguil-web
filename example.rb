$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'

require 'sguil'
include Sguil::Helpers::Commands

@sguil = Sguil.connect({:client => '0.0.0.0', :verbose => true})

puts @sguil

@sguil.login('demo', 'demo')
@sguil.sensor_list

