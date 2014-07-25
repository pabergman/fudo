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

Roadmap
===

* Support more value-types (dateformats, password)
* More indepth testing of parameters (max int/min int)
* More indepth testing of types ("true", 1 and false)
* Support modifying headers 
* Support building URL from variables
* Rebuild support for testing response bodies (using json-schema)
* Suggestion engine!
