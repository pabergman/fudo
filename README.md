fudo
====

What is fudo? It is a framework for testing RESTful APIs! 

Why does it exist? Because testing RESTful APIs is incredibly annoying, why do you need to write both JSON and code to test something?! You end spending more time writing tests than actually implementing it. Not to mention that, most APIs are woefully undertested, it's understandable, unhappy paths grow exponentially so you'll test one or two and leave it at that.

To give some context, assuming the following JSON object:

{
  "name": "MyPet",
  "id": "1120",
  "owner": {
    "first_name": "John",
    "surname": "Roberts",
    "phone_number": "1-167-097-4708"
  }
}

fudo will currently run 22 unhappy paths. Crafting that many unhappy paths by hand would be a massive timesink.

Instructions
===

Make sure you have the following installed:
1) Ruby, 2.0.0 or later
2) bundle gem, to install just run "gem install bundle"

Now pull the git repo:
git clone https://github.com/pabergman/fudo.git ~/fudo
Run "bundle install" in the git directory

Create a test directory, feel free to copy the one in the repo.
It needs to to contain both the test-directory.json and global-variables.json file and a subdirectory called tests.
Any test you create needs to be entered into test-directory.json with it's name and relative path, see examples.

To create a test, go to lib, use the following command:
ruby parser.rb
Enter the inputs, copy paste the output into a text file, add it to the test-directory.json file. If you need json-schema validation, please copy paste that into response:body{}, a generator can be found http://jsonschema.net/reboot/#/

Copy example-config.yml, replace the root_dir with the absolute path to your folder containting test-directory.json (you can edit other variables if you feel it necessary).

To run the test, use ruby fudo.rb {path to config.yml} {testname}

eg: ruby fudo.rb ~/Projects/fudo/config.yaml oneunique


Roadmap
===

* Create an test API.... 
* Support more value-types (dateformats, password)
* More indepth testing of parameters (max int/min int)
* More indepth testing of types (supports boolean now, other types should be tested)
* Support modifying headers 
* Support building URL from variables
* Suggestion engine!
