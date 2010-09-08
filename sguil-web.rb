$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'sinatra'
require 'faye'
require 'pp'

require 'sguil'

enable :sessions
use Faye::RackAdapter, :mount => '/sguil', :timeout => 20

configure do
end

helpers do
  def has_session?
    return true if defined?(@fork)
    false
  end
end

get '/' do
  redirect '/welcome' unless has_session?
  erb :events
end

get '/welcome' do
  erb :welcome
end

get '/login' do
  unless has_session?
    @sguil = Sguil::Connect.new({:client => env['HTTP_HOST']}, true)
    @sguil.login({:username => 'demo', :password => 'demo'})
    session[:username] = 'demo'
    session[:ipaddr] = env['REMOTE_ADDR']
    session[:agent] = env['HTTP_USER_AGENT']
    session[:lang] = env['HTTP_ACCEPT_LANGUAGE']
    @fork = Thread.new { @sguil.receive_data }
    redirect '/' if has_session?
  else
    redirect '/welcome'
  end
end

get '/logout' do
  begin
    @sguil.kill! if defined?(@sguil)
  rescue IOError
  ensure
    redirect '/welcome'
  end
end

get '/sensor_updates' do
  erb :sensor_updates
end

#
# Faye Subscriptions
# 
# All commands sent from the sguild
# server to be published to connected
# client.
# 
post '/sensor/updates' do
  env['faye.client'].publish('/sensor', params)
  "PUSH ADDED"
end

post '/user/message' do
  env['faye.client'].publish('/usermsg', params)
  "USERMSG"
end

post '/system/message' do
  env['faye.client'].publish('/system_message', params)
  "SYSMSG"
end

post '/events/insert' do
  env['faye.client'].publish('/system_message', params)
  "SYSMSG"
end

# Send Commands
# 
# All commands that are sent to
# the sguild server.
#
get '/sensor_list' do
  @sguil.sensor_list if has_session?
  'SENSOR_LIST'
end

post '/connect' do
  @sguil.monitor('DEMO_DMZ') if has_session?
  "CONNECT" 
end

get '/connect' do
  @sguil.sensor('demo') if has_session?
  "CONNECT" 
end

post '/send/message' do
  @sguil.send_message("#{params[:msg]}")
end
