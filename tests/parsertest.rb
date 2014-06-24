#Testing Parser
require_relative('../lib/parser')

#Test One
input_file = open('data/parser/input-one.json')
output_file = open('data/parser/output-one.json')

input_json = JSON.parse(input_file.read)
expected_json = JSON.parse(output_file.read)

output_json = JSON.parse('{}')


FudoJsonGenerator.master(input_json, output_json);



if JSON.pretty_generate(expected_json).eql? JSON.pretty_generate(output_json)
else
	abort('test failed')
end