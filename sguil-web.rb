$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'sinatra'
require 'faye'
require 'pp'

require 'sguil'

enable :sessions
use Faye::RackAdapter, :mount => '/sguil', :timeout => 20

configure do
  
  
  #
  # Depending On The Web Server You
  # May Need To Set The Below Manually
  @@sguil_web_server = env['HTTP_HOST']

  trap('SIGINT') do
    Sguil.kill_all!
    session = {}
  end

end

helpers do
  def has_session?
    return true if Sguil.has(session[:client_id])
    false
  end

  def current_user
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
    session[:client_id] = Sguil.uid
    
    Sguil.add_client(session[:client_id], Sguil::Connect.new({:verbose => true, :uid => session[:client_id]}))
    
    Sguil.get(session[:client_id]).login({:username => params[:username], :password => 'demo'})
    
    # @@sguil.login({:username => params[:username], :password => 'demo'})
    
    session[:login] = true
    session[:username] = 'demo'
    session[:ipaddr] = env['REMOTE_ADDR']
    session[:agent] = env['HTTP_USER_AGENT']
    session[:lang] = env['HTTP_ACCEPT_LANGUAGE']
    
    
    Sguil.add_fork(session[:client_id], Thread.new { Sguil.get(session[:client_id]).receive_data })
    #@@fork = Thread.new { @@sguil.receive_data }
    redirect '/' if has_session?
  else
    redirect '/welcome'
  end
end

get '/logout' do
  begin
    Sguil.kill(session[:client_id])
    session = {}
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
  env['faye.client'].publish("/sensor/#{params[:uid]}", params)
  "PUSH ADDED"
end

post '/user/message' do
  env['faye.client'].publish("/usermsg/#{params[:uid]}", params)
  "USERMSG"
end

post '/system/message' do
  env['faye.client'].publish("/system_message/#{params[:uid]}", params)
  "SYSMSG"
end

post '/insert/events' do
  env['faye.client'].publish("/add_event/#{params[:uid]}", params)
  "SYSMSG"
end

# Send Commands
#
# All commands that are sent to
# the sguild server.
#
get '/sensor_list' do
  Sguil.get(session[:client_id]).sensor_list if has_session?
  'SENSOR_LIST'
end

post '/connect' do
  Sguil.get(session[:client_id]).monitor('DEMO_DMZ') if has_session? #&& defined?(@@sguil)
  "CONNECT"
end

get '/connect' do
  Sguil.get(session[:client_id]).sensor('demo') if has_session?
  "CONNECT"
end

post '/send/message' do
  Sguil.get(session[:client_id]).send_message("#{params[:msg]}")
end
