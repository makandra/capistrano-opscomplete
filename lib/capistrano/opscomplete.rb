require 'capistrano/opscomplete/version'

load File.expand_path('opscomplete/ruby.rake', __dir__)
load File.expand_path('opscomplete/supervisor.rake', __dir__)
load File.expand_path('opscomplete/deploy.rake', __dir__)
