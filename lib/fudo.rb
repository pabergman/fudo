require 'yaml'
require 'json'

module Fudo

	ROOT = "../"

	CONFIG = YAML.load_file(ROOT << "config.yaml")

	GLOBAL_VARIABLES = JSON.parse(open(CONFIG['root_dir']+"global-variables.json").read)

	TEST_ROOT = JSON.parse(open(CONFIG['root_dir']+"test-directory.json").read)

end

