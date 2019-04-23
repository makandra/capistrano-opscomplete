# Capistrano::Opscomplete

This gem provides capistrano tasks for convenient deployment to a makandra [OpsComplete for Ruby](https://opscomplete.com/ruby) environment. If you find any bugs or run into a problem, please drop us a mail or open an issue.

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

    $ bundle exec cap -T opscomplete

Now, add some [hooks](#using-capistrano-hooks) in your capistrano configuration (e.g. `deploy.rb`).
An example configuration could look like this:

```ruby
# After unpacking your release, before bundling, compiling assets, ...
after 'deploy:updating', 'opscomplete:ruby:ensure'
```

and in case you enabled [`Procfile support`](https://makandracards.com/opscomplete/67829-procfile-support) this can be enabled:

```ruby
# Update and Restart supervisor config
after 'deploy:updating', 'opscomplete:supervisor:gen_config'
after 'deploy:published', 'opscomplete:supervisor:restart_procs'
```

## Usage

If you encounter any errors, please make sure you have the newest version of the capistrano-opscomplete gem installed. Don't hesitate to contact the OpsComplete for Ruby team for further support.

You might also want to configure some hooks to automatically update the ruby version, see [using capistrano hooks](#using-capistrano-hooks).


### List available tasks

To see available capistrano tasks, execute:

    $ bundle exec cap -T


### opscomplete:ruby:check

The `opscomplete:ruby:check` task checks for a properly configured ruby. It will not try to correct any misconfigurations, but just abort the capistrano run.

    $ bundle exec cap <ENVIRONMENT> opscomplete:ruby:check

Where `<ENVIRONMENT>` could be `production`, `staging`, ...


### opscomplete:ruby:ensure

The `opscomplete:ruby:ensure` task checks for a ruby as requested in application's `.ruby-version` file and will try to correct some misconfigurations.

    $ bundle exec cap <ENVIRONMENT> opscomplete:ruby:ensure

Where `<ENVIRONMENT>` could be `production`, `staging`, ...

More specifically this task will:
  - Check whether you are running a 'managed ruby' (installed with OpsComplete for Ruby) or if you have to install ruby using this gem or rbenv.
  - If you are using 'unmanaged ruby':
    - Check if desired ruby version is installed. The following lookup precedence for the desired version is being used:
      1) The value of `:opscomplete_ruby_version` from your capistrano config. Leave this empty unless you want to override the desired version.
      2) A file in the `release_path` on the server (e.g. `/var/www/staging.myapp.biz/releases/20180523234205/.ruby-version`)
      3) A file in the current working directory of your local checkout (e.g. `/home/user/code/myapp/.ruby-version`)
    - If the desired version is not installed, it checks if it can be installed using `ruby-build` and installs it.
    - Check if `rbenv global` version is set according to application's `.ruby-version` file. Change it if required.
    - Install the `bundler` and `geordi` gem if required.
    - Run `rbenv rehash` if required.

**Note:** If, for any reason, no `.ruby-version` file can be found in your release or current working directory, you may set the following option in `deploy.rb`:

```ruby
set :opscomplete_ruby_version, '<VERSION>'
```

**Optional:** By default, the ruby version is checked/installed for all server roles. If you want to limit the rbenv operations to certain roles, set `rbenv_roles` in your `deploy.rb`:

```ruby
set :rbenv_roles, :web
# or
set :rbenv_roles, [:web, :worker]
```

**Optional:** By default, the most recent version of bundler will be installed. If you want a specific bundler version available for your release, set it in your `deploy.rb`:

```ruby
set :bundler_version, '<VERSION>'
```

**Optional:** By default, the rubygems version defined by the ruby-build manifest will be installed. If you want a specific rubygems version available for your release, set it in your `deploy.rb`:

```ruby
set :rubygems_version, '<VERSION>'
```

### Using capistrano hooks

There are many hooks available in the [default deploy flow](https://capistranorb.com/documentation/getting-started/flow/) to integrate tasks into your own deployment configuration. To ensure a ruby version according to your application is installed during deployment, add the following to your `Capfile`.

```ruby
after 'deploy:updating', 'opscomplete:ruby:ensure'
```

## Contributing

Bug reports and pull requests are welcome. Don't hesitate to [open a new issue](https://github.com/makandra/capistrano-opscomplete/issues/new).
