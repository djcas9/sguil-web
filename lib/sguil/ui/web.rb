#
# SguilWeb - A web client for the popular Sguil security analysis tool.
#
# Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'sinatra'
require 'faye'

module Sguil
  module UI
    class Web < Sinatra::Base
      
      helpers Sguil::Helpers::Web
      
      set :run, true
      set :root, File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','data','sguil'))
      
      enable :sessions
      use Faye::RackAdapter, :mount => '/sguil'

      configure do

        trap('SIGINT') do
          Sguil.kill_all!
          session = {}
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
            :client => sguil_web_server,
            :faye => env['faye.client'],
            #:logger => [:verbose, :info],
            :uid => user_id
          }))

          # :logger => [:verbose, :info],

          current_user.login({:username => (params[:username] || params[:username] = 'demo'), :password => 'demo'})

          if current_user.connected?
            
            session[:login] = true
            session[:username] = params[:username]
            session[:ipaddr] = env['REMOTE_ADDR']
            session[:agent] = env['HTTP_USER_AGENT']
            session[:lang] = env['HTTP_ACCEPT_LANGUAGE']
            
            Sguil.add_fork(user_id, Thread.new { current_user.receive_data })
            redirect '/' if has_session?
          
          else
            
            redirect '/welcome'
            
          end

        else
          redirect '/welcome'
        end
      end

      get '/logout' do
        Sguil.logout(current_user) if current_user
        session = {}
        redirect '/welcome'
      end

      get '/sensor_updates' do
        erb :sensor_updates
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
        current_user.monitor(params[:sensors]) if has_session?
        "CONNECT"
      end

      get '/connect' do
        return "#{current_user.sensor_list}" if has_session?
        ""
      end

      post '/send/message' do
        current_user.send_message("#{params[:msg]}")
      end
      
      
    end
    
  end
end