# vim: filetype=ruby
require 'capistrano/dsl/opscomplete'

namespace :opscomplete do
  include Capistrano::DSL::Opscomplete
  # desc 'Validate opscomplete specific configuration'
  task :validate do
    invoke('opscomplete:ruby:check')
  end

  namespace :ruby do
    # desc 'Rehash rbenv shims (run this after installing executables).'
    task :rehash do
      on roles fetch(:rbenv_roles, :all) do
        execute(:rbenv, :rehash)
      end
    end

    desc 'Check if rbenv global ruby is set according to application\'s .ruby-version.'
    task :check do
      on roles fetch(:rbenv_roles, :all) do |host|
        warn("#{host}: Managed ruby environment! Won't do any changes to ruby version.") if managed_ruby
        unless capture(:rbenv, :global) == app_ruby_version
          raise Capistrano::ValidationError,
                "#{host}: Ruby version is not set according to application\'s .ruby-version file. Use cap opscomplete:ruby:ensure."
        end
        info("#{host}: Required ruby version '#{app_ruby_version}' is installed.")
      end
    end

    # desc 'Install rbenv plugin ruby-build'
    task :install_ruby_build do
      on roles fetch(:rbenv_roles, :all) do
        next if test "[ -d #{rbenv_ruby_build_path} ]"
        execute :git, :clone, ruby_build_repo_url, rbenv_ruby_build_path
      end
    end

    # desc 'Update rbenv plugin ruby-build'
    task :update_ruby_build do
      on roles fetch(:rbenv_roles, :all) do
        if test "[ -d #{rbenv_ruby_build_path} ]"
          within rbenv_ruby_build_path do
            execute :git, :pull, '-q'
          end
        else
          warn('Could not find ruby-build.')
        end
      end
    end

    # desc 'Install bundler gem'
    task :install_bundler do
      on roles fetch(:rbenv_roles, :all) do
        next if test(:rbenv, :exec, :gem, :query, '--quiet --installed --name-matches ^bundler$')
        execute(:rbenv, :exec, :gem, :install, :bundler, '--quiet --no-rdoc --no-ri')
        set :rbenv_needs_rehash, true
      end
    end

    # desc 'Install geordi gem'
    task :install_geordi do
      on roles fetch(:rbenv_roles, :all) do
        next if test(:rbenv, :exec, :gem, :query, '--quiet --installed --name-matches ^geordi$')
        execute(:rbenv, :exec, :gem, :install, :geordi, '--quiet --no-rdoc --no-ri')
        set :rbenv_needs_rehash, true
      end
    end

    desc 'Install and configure ruby according to applications .ruby-version.'
    task :ensure do
      on roles fetch(:rbenv_roles, :all) do |host|
        if managed_ruby
          raise Capistrano::ValidationError, "#{host}: Managed ruby environment! Won't do any changes to ruby version."
        end
        if rbenv_installed_rubies.include?(app_ruby_version)
          info("#{host}: Required ruby version '#{app_ruby_version}' is installed.")
        else
          invoke('opscomplete:ruby:update_ruby_build')
          if rbenv_installable_rubies.include?(app_ruby_version)
            info("#{host}: Required ruby version is not installed, but available for installation.")
            execute(:rbenv, :install, app_ruby_version)
            set :rbenv_needs_rehash, true
          else
            raise Capistrano::ValidationError,
                  "#{host}: Ruby version required by application is neither installed nor installable using ruby-install."
          end
        end
        execute(:rbenv, :global, app_ruby_version) unless capture(:rbenv, :global) == app_ruby_version
      end
      invoke('opscomplete:ruby:install_bundler')
      invoke('opscomplete:ruby:install_geordi')
      invoke('opscomplete:ruby:rehash') if fetch(:rbenv_needs_rehash, false)
    end
  end
end
