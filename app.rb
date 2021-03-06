# encoding: utf-8
require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'erb'
require 'data_mapper'
require "sinatra/reloader" if development?
require 'date'
require 'rack-datamapper-session'

# Database
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db.sqlite3")

#Session

use Rack::Session::DataMapper, :expire_after => 15*24*3600 # 2 semanas

# Models

class User
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String
  
  has n,   :drinkRecords
  
  def drinks_by_month(month, year)
    st_time = Date.new(year, month)
    fin_time = st_time.next_month
    drinkRecords.all(:created_at => (st_time.to_time..fin_time.to_time))
  end
  
  # Some utility methods - naming sucks.
  
  def drinks(type)
    drinkRecords.all(:type => type)
  end
  
  def num_drinks(type)
    drinkRecords.all(:type => type).size
  end
  
  def total_price
    sprintf "%.2f", drinkRecords.map(&:price).inject(:+) || 0 # Using sprintf to avoid weird float errors (0.5999999 instead of 0.6).
  end
  
  def type_price(type)
    sprintf "%.2f", drinks(type).map(&:price).inject(:+) || 0
  end
end

class DrinkRecord
  include DataMapper::Resource
  property :id,           Serial
  property :created_at,   DateTime
  property :type,         Enum[:intenso, :aromatico], :required => true   # Add new types here and on the views (they're hardcoded)
  property :price,        Float, :default => 0.3
  
  belongs_to :user
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
  erb :"admin/index"
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

get '/admin/user/:id' do
  protected!
  @user = User.get(params[:id])
  erb :"admin/user"
end

post '/login' do
  session[:user] = User.get(params[:id]).id
  call env.merge("PATH_INFO" => '/' + params[:action])
end

get '/logout' do
  session.clear
  redirect '/'
end

post '/:action' do |action|
  halt 404 unless DrinkRecord::type.options[:set].include? action.to_sym
  
  unless @me
    @users = User.all
    return erb :login, :locals => {:action => action}
  end
  
  @me.drinkRecords.create(:type => action.to_sym)
  
  erb :done, :locals => {:confirmation_msg => ["Registado.", "Ok, já apontei.", "Done.", "Agora vai trabalhar.", "E Red Bull, não?"].sample}
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
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['ADMIN_USERNAME'] || 'admin', ENV['ADMIN_PASSWORD'] || 'password']
  end

end