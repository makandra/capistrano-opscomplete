require 'capistrano/opscomplete/version'

# Need to require rake before we can use the Rake DSL (task do ..., namespace do, ...)
require 'rake'

load File.expand_path('opscomplete/ruby.rake', __dir__)
load File.expand_path('opscomplete/nodejs.rake', __dir__)
load File.expand_path('opscomplete/supervisor.rake', __dir__)
