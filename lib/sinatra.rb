require 'sinatra'
require 'json'

fname = Array.new
sname = {}
dualname = {}

get '/' do
  'Hello world!'
end

post '/unique/oneunique' do
	request_payload = JSON.parse(request.body.read)
	if(request_payload['name'] == nil)

	elsif(fname.include?(request_payload['name']))
		 status 409
	else 
		fname << request_payload['name']
		status 200
	end
	body fname.to_json
end



get '/unique/sname' do
	body sname.to_json
end

get '/unique/dualname' do
	set :fname, "moo"
	  "foo is set to " + settings.fname
end

post '/fname' do
  "foo is set to " + settings.fname
end
