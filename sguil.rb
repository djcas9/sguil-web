$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'sinatra'
require 'socket'
require 'faye'
require 'set'
require 'pp'

require 'sguild'

enable :sessions
use Faye::RackAdapter, :mount => '/sguil', :timeout => 20

configure do
end

helpers do

  def has_session?
    return true if defined?(@@sguilproc)
    false
  end

end

get '/' do
  redirect '/welcome' unless has_session?
  erb :sensors
end

get '/welcome' do
  erb :welcome
end

get '/login' do
  unless has_session?
    @@sguilsocket = Sguild::Connect.new({:client => env['HTTP_HOST']}, true)
    @@sguilsocket.login({:username => 'demo', :password => 'guest'})
    session[:username] = 'demo'
    session[:ipaddr] = env['REMOTE_ADDR']
    session[:agent] = env['HTTP_USER_AGENT']
    session[:lang] = env['HTTP_ACCEPT_LANGUAGE']
    @@sguilproc = Thread.new { @@sguilsocket.run! }
    redirect '/' if has_session?
  else
    redirect '/welcome'
  end
end

post '/connect' do
  @@sguilsocket.sensor('demo') if has_session?
  "CONNECT" 
end

get '/logout' do
  begin
    @@sguilsocket.kill! if defined?(@@sguilsocket)
  rescue IOError
  ensure
    redirect '/welcome'
  end
end

post '/sensor' do
  env['faye.client'].publish('/sensor', params)
  "PUSH ADDED"
end

post '/usermsg' do
  env['faye.client'].publish('/usermsg', params)
  "USERMSG"
end

get '/sensor_updates' do
  erb :sensor_updates
end

post '/system_message' do
  env['faye.client'].publish('/system_message', params)
  "SYSMSG"
end

post '/sendmsg' do
  @@sguilsocket.sendmsg("#{params[:msg]}")
end
