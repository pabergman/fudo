require 'sinatra'
require 'json'

dualname = {}

get '/' do
  'Hello world!'
end

oneunique = Array.new

post '/unique/oneunique' do
	request_payload = JSON.parse(request.body.read)
	if(request_payload['name'] == nil)
		status 200
	elsif(oneunique.include?(request_payload['name']))
		 status 409
	else 
		oneunique << request_payload['name']
		status 200
	end
	body oneunique.to_json
end

twounique = Array.new

post '/unique/twounique' do
	request_payload = JSON.parse(request.body.read)

	if(request_payload['firstname'] == nil || request_payload['surname'] == nil)
		status 200
	elsif(twounique.include?(request_payload['firstname']) || twounique.include?(request_payload['surname']))
		 status 409
	else 
		twounique << request_payload['firstname']
		twounique << request_payload['surname']
		status 200
	end

	body twounique.to_json
end

get '/unique/sname' do
	body sname.to_json
end

get '/unique/dualname' do
	set :oneunique, "moo"
	  "foo is set to " + settings.oneunique
end

post '/oneunique' do
  "foo is set to " + settings.oneunique
end
