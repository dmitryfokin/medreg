require 'rubygems'
require 'sinatra'
require "json"
require 'open-uri'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end


get '/gettest' do
  jsonText = ''

  open("https://uslugi.mosreg.ru/zdrav/find_lpu/get_doctors/3801661/")  do |f|

    f.each_line do |line|
      jsonText += line
      #p line.class
    end
  end

  med_3801661 = JSON.load(jsonText)

  specs = med_3801661['specs']
  pediatrics = {'pediatrics' => specs['Педиатрия']}

  #pediatrics = {'test' => 'test'}
  return JSON(pediatrics)
end


get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
