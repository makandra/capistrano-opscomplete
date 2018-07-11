# Capistrano::Opscomplete

This gem provides capistrano tasks for convenient deployment to a makandra [OpsComplete for Ruby](https://opscomplete.com/ruby) environment. If you find any bugs or run
into a problem, please drop us a mail or open an issue.

## Installation

Include the gem in your applications Gemfile:

```ruby
gem 'capistrano-opscomplete'
```

And then execute:

    $ bundle

Or install it manually with:

    $ gem install capistrano-opscomplete

Now, include the DSL extensions and tasks by adding the following line to your `Capfile` _after_ `capistrano/deploy`:

```ruby
require 'capistrano/opscomplete'
```

Verify the gem was installed and tasks are available:

    $ bundle exec cap -T | grep opscomplete

Optional: If you want to manage ruby versions for certain roles, set `rbenv_roles` in your `deploy.rb`:

```ruby
set :rbenv_roles, :app
```

You might also want to configure some hooks, see [using capistrano hooks](#using-capistrano-hooks).

## Usage

If you encounter any errors, please make sure you have the newest version of the capistrano-opscomplete gem installed. Don't hesitate to
contact the OpsComplete for Ruby team for further support.

### List available tasks

To see available capistrano tasks, execute:

    $ bundle exec cap -T

### opscomplete:ruby:check

The `opscomplete:ruby:check` task checks for a properly configured ruby. It will not try to correct any misconfigurations, but just abort
the capistrano run.

    $ bundle exec cap <ENVIRONMENT> opscomplete:ruby:check

Where `<ENVIRONMENT>` could be `production`, `staging`, ...

### opscomplete:ruby:ensure

The `opscomplete:ruby:ensure` task checks for a ruby as requested in application's `.ruby-version` file and will try to correct some
misconfigurations.

    $ bundle exec cap <ENVIRONMENT> opscomplete:ruby:ensure

Where `<ENVIRONMENT>` could be `production`, `staging`, ...

More specifically this task will:
  - Check whether you are running a 'managed ruby' (installed with OpsComplete for Ruby) or if you have to install ruby using this gem or rbenv.
  - If you are using 'unmanaged ruby':
    - Checks if ruby version requested by `.ruby-version` is installed.
    - If it is not installed, checks if it can be installed using `ruby-build` and installs it.
    - Check if `rbenv global` version is set according to application's `.ruby-version` file. Change it if required.
    - Install the `bundler` and `geordi` gem if required.
    - Run `rbenv rehash` if required.

*Note:* If, for any reason, no `.ruby-version` file can be found in your release directory, you may set the following option in
deploy.rb:

```ruby
set :opscomplete_ruby_version, '<VERSION>'
```

Where `<VERSION>` is the desired ruby version.

### opscomplete:appserver:restart

To restart your application server execute:

    $ bundle exec cap <ENVIRONMENT> opscomplete:appserver:restart

Where `<ENVIRONMENT>` could be `production`, `staging`, ...

Note: The current version of this gem only support the passenger app server. The current version of this gem does not support restarting your application, if multiple instances of passenger are running on the same host. This would be the case if you have Apache _and_ Nginx servers running on the same host.

### Using capistrano hooks

There are many hooks in the [default deploy flow](https://capistranorb.com/documentation/getting-started/flow/) to integrate tasks into your own deployment configuration. To ensure a ruby version according to your application is installed during deployment, add the following to your `Capfile`.

```ruby
before 'deploy:starting', 'opscomplete:ruby:ensure'
after 'deploy:published', 'opscomplete:appserver:restart'
```

## Contributing

Bug reports and pull requests are welcome.
