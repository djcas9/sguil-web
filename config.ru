$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
dir = ::File.dirname(__FILE__)

require 'rubygems'
require 'sguil'
require 'faye'

use Faye::RackAdapter, :mount => '/sguil', :timeout => 20
run Sinatra::Application