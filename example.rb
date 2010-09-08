$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'sguil'

include Sguil::Helpers::Commands

@test = Sguil.connect({:client => '0.0.0.0', :verbose => true})

