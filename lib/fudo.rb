require_relative 'fudo/schema_generator'
require_relative 'fudo/body_builder'

module Fudo

end

# #!/usr/bin/env ruby
# require 'yaml'
# require 'json'
# require_relative 'run_test'
# require_relative 'parser'

# class Fudo
#   ROOT = '../'

#   CONFIG = YAML.load_file(ARGV[0])

#   GLOBAL_VARIABLES = JSON.parse(open(CONFIG['root_dir'] + 'global-variables.json').read)

#   TEST_ROOT = JSON.parse(open(CONFIG['root_dir'] + 'test-directory.json').read)

#   commandlineinput = ARGV[1]

#   full_request = JSON.parse(open(Fudo::CONFIG['root_dir'] + '/tests/' + Fudo::TEST_ROOT[commandlineinput]).read)

#   RunTest.run(full_request)
# end
