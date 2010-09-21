$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require 'rubygems'
require 'sinatra'
require 'faye'
require 'pp'

require 'sguil'

enable :sessions
use Faye::RackAdapter, :mount => '/sguil', :timeout => 20

configure do

  # Depending On The Web Server You
  # May Need To Set The Below Manually
  @@sguil_web_server = '0.0.0.0:3000'

  trap('SIGINT') do
    Sguil.kill_all!
    session = {}
  end

end

helpers do

  def user_id
    session[:client_id]
  end

  def has_session?
    return true if Sguil.has(user_id)
    false
  end

  def current_user
    Sguil.get(user_id)
  end
  
  def sguil_web_server
    @@sguil_web_server
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

    #
    # Create User Session
    #
    # Login to the sguil server &
    # return a socket.
    #
    session[:client_id] = Sguil.uid
    
    Sguil.add_client(user_id, Sguil::Connect.new({
      :client => @@sguil_web_server,
      :logger => [:verbose, :debug, :info],
      :uid => user_id
    }))
    
    # current_user.login({:username => params[:username], :password => 'demo'})
    # 
    # session[:login] = true
    # session[:username] = 'demo'
    # session[:ipaddr] = env['REMOTE_ADDR']
    # session[:agent] = env['HTTP_USER_AGENT']
    # session[:lang] = env['HTTP_ACCEPT_LANGUAGE']
    # 
    # 
    # Sguil.add_fork(user_id, Thread.new { current_user.receive_data })

    redirect '/' if has_session?
  else
    redirect '/welcome'
  end
end

get '/logout' do
  begin
    Sguil.kill(user_id)
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
  current_user.sensor_list if has_session?
  'SENSOR_LIST'
end

post '/connect' do
  current_user.monitor('DEMO_DMZ') if has_session?
  "CONNECT"
end

get '/connect' do
  current_user.sensor(params[:sensors]) if has_session?
  "CONNECT"
end

post '/send/message' do
  current_user.send_message("#{params[:msg]}")
end
