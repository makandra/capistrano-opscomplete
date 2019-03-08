lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/opscomplete/version'

Gem::Specification.new do |spec|
  spec.name     = 'capistrano-opscomplete'
  spec.version  = Capistrano::Opscomplete::VERSION
  spec.authors  = ['Makandra Operations']
  spec.email    = ['ops@makandra.de']

  spec.summary  = %q(Capistrano tasks for easy deployment to a makandra opscomplete environment.)
  spec.homepage = 'https://opscomplete.com/ruby'

  spec.license  = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^((test|spec|features)/|.gitignore|.rubocop.yml)}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r(^exe/)) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_rubygems_version = '>=2.0.1'

  spec.add_development_dependency 'makandra-rubocop'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'capistrano', '>=3.0', '<4.0.0'
end
