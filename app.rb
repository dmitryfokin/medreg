require 'rubygems'
require 'sinatra'
require "json"
require 'open-uri'

def getHashDoctor
  h = {
      'person_id' => '',
      'displayName' => '',
      'type_name' => '',
      'room' => '',
      'photo' => '',
      'rating' => '',
  }

end

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
  pediatrics = { 'pediatrics' => [] }

  med_3801661['specs']['Педиатрия'].each do |item|

    doctor = getHashDoctor
    doctor.each {|key, value| doctor[key] = item[key] if (item[key])}
    doctor['schedule'] = []

    item['schedule'].each do |itemSchedule|

      scheduleDay = {}
      scheduleDay['date'] = itemSchedule['date']
      scheduleDay['day'] = itemSchedule['formatting']['day']
      scheduleDay['dateStr'] = itemSchedule['formatting']['date']
      scheduleDay['time_from'] = itemSchedule['time_from']
      scheduleDay['time_to'] = itemSchedule['time_to']
      scheduleDay['name'] = itemSchedule['docBusyType']['name']
      scheduleDay['code'] = itemSchedule['docBusyType']['code']
      scheduleDay['count_tickets'] = itemSchedule['count_tickets']

      doctor['schedule'] << scheduleDay
    end

    pediatrics['pediatrics'] << doctor

  end

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
