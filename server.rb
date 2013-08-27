require 'sinatra'

#Para executar use o comando - ruby server.rb -p $PORT -o $IP
#set :bind, '127.0.0.1'
#set :port, 3000

def get_revision
    300
end

get '/' do
    "Hello World!"
end

get '/api/v1/itinerarios' do
  content_type :json
  File.read(File.join('./', 'temp.json'))
end

get '/api/v1/pontos_de_recarga' do
  content_type :json
  File.read(File.join('./', 'points_of_charge.json'))
end


get '/api/v1/revision' do
  get_revision.to_s
end