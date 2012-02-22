require 'rubygems'
require 'sinatra'
require 'erb'

require 'data_mapper'
require "sinatra/reloader" if development?

enable :sessions

# Models
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db.sqlite3")

class User
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String
  property :aromatico,    Integer, :default => 0
  property :intenso,      Integer, :default => 0
end

DataMapper.finalize
DataMapper.auto_upgrade!

# Controllers

before do
  @me = User.get(session[:user]) if session[:user]
end

get '/' do
  @users = User.all
  erb :index
end

get '/admin' do
  protected!
  @users = User.all
  erb :admin
end

post '/add' do
  protected!
  User.create(:name => params[:name])
  redirect '/admin'
end

post '/remove' do
  protected!
  User.get(params[:id]).destroy
  redirect '/admin'
end

post '/login' do
  session[:user] = User.get(params[:id]).id
  call env.merge("PATH_INFO" => '/' + params[:action])
end

get '/logout' do
  session[:user] = nil
  redirect '/'
end

post '/:action' do |action|
  halt 404 unless ["aromatico", "intenso"].include? action
  
  unless @me
    @users = User.all
    return erb :login, :locals => {:action => action}
  end
  
  @me[action] += 1
  @me.save
  
  erb :done, :locals => {:confirmation_msg => ["Registado.", "Ok, já apontei.", "Done.", "Agora vai trabalhar.", "E Red Bull, não?"].choice}
end

# Helpers

helpers do

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'connect_cbr!']
  end

end