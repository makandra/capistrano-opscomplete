# vim: filetype=ruby
require 'capistrano/dsl/opscomplete'

namespace :opscomplete do
  include Capistrano::DSL::Opscomplete
  # desc 'Validate opscomplete specific configuration'
  task :validate do
    invoke('opscomplete:ruby:check')
  end

  namespace :ruby do
    desc 'Check if Ruby version is set according to application\'s .ruby-version.'
    task :check do
      on roles fetch(:rbenv_roles, :all) do |host|
        warn("#{host}: Managed Ruby environment! Won't do any changes to ruby version.") if managed_ruby?
        unless capture(:ruby_get_current_version) == app_ruby_version
          raise Capistrano::ValidationError,
                "#{host}: Ruby version is not set according to application\'s .ruby-version file. Use cap opscomplete:ruby:ensure."
        end
        info("#{host}: Ruby #{app_ruby_version} is installed.")
      end
    end

    desc 'Install Ruby version management tool dependencies'
    task :install_ruby_build do
      on roles fetch(:rbenv_roles, :all) do
        execute(:ruby_update_management_tool, :install_build)
      end
    end

    desc 'Update Ruby version management tool'
    task :update_ruby_build do
      on roles fetch(:rbenv_roles, :all) do
        execute(:ruby_update_management_tool, :update_build)
      end
    end

    desc 'Rehash shims (run this after installing executables).'
    task :rehash do
      on roles fetch(:rbenv_roles, :all) do
        execute(:ruby_update_management_tool, :rehash)
      end
    end

    desc 'Install bundler gem'
    task :install_bundler do
      on roles fetch(:rbenv_roles, :all) do
        # manually specified version will take precedence
        specific_bundler_version = fetch(:bundler_version, app_gemfile_bundled_with_version)
        if specific_bundler_version
          # We have to set force = true to overwrite the binary
          gem_install('bundler', specific_bundler_version, true) unless gem_installed?('bundler', specific_bundler_version)
        else
          gem_install('bundler') unless gem_installed?('bundler')
        end
      end
    end

    desc 'Install geordi gem'
    task :install_geordi do
      on roles fetch(:rbenv_roles, :all) do
        gem_install('geordi') unless gem_installed?('geordi')
      end
    end

    desc 'Install RubyGems'
    task :install_rubygems do
      on roles fetch(:rbenv_roles, :all) do
        # if no rubygems_version was set, we use and don't check the installed rubygems version
        if fetch(:rubygems_version, false)
          current_rubygems_version = capture(:ruby_get_current_version, :rubygems).chomp
          info("Ensuring requested RubyGems version #{fetch(:rubygems_version)}")
          next if current_rubygems_version == fetch(:rubygems_version)
          info("Previously installed RubyGems version was #{current_rubygems_version}")
          execute(:ruby_install_version, :rubygems, "'#{fetch(:rubygems_version)}'")
        end
      end
    end

    desc 'Install and configure ruby according to applications .ruby-version.'
    task :ensure do
      invoke('opscomplete:ruby:update_ruby_build')
      on roles fetch(:rbenv_roles, :all) do |host|
        if managed_ruby?
          raise Capistrano::ValidationError, "#{host}: Managed Ruby environment! Won't do any changes to Ruby version."
        end
        if ruby_installed_versions.include?(app_ruby_version)
          info("#{host}: Ruby #{app_ruby_version} is installed.")
        elsif ruby_installable_versions.include?(app_ruby_version)
          info("#{host}: Configured Ruby version is not installed, but available for installation.")
          with tmpdir: fetch(:tmp_dir) do
            execute(:ruby_install_version, "'#{app_ruby_version}'")
          end
        else
          raise Capistrano::ValidationError,
                "#{host}: Configured Ruby version is neither installed nor installable."
        end
        unless capture(:ruby_get_current_version) == app_ruby_version
          set :ruby_modified, true
          execute(:ruby_set_version, "'#{app_ruby_version}'")
        end
      end
      invoke('opscomplete:ruby:install_rubygems')
      invoke('opscomplete:ruby:install_bundler')
      invoke('opscomplete:ruby:install_geordi')
      invoke('opscomplete:ruby:rehash')
    end

    desc 'resets the global ruby version and gems to Gemfile and .ruby-version in current_path.'
    task :reset do
      on roles fetch(:rbenv_roles, :all) do |host|
        within current_path do
          current_ruby_version_file_path = current_path.join('.ruby-version').to_s
          if test("[ -f #{current_ruby_version_file_path} ]")
            execute(:rbenv, :global, capture(:cat, current_ruby_version_file_path))
          else
            raise Capistrano::ValidationError,
                  "#{host}: Missing .ruby-version in #{current_path}. Won't set a new global version."
          end
          if test("[ -f '#{current_path}/.bundle/config' ]")
            debug("#{host}: Found #{current_path}/.bundle/config, running bundle pristine.")
            set :bundle_gemfile, -> { current_path.join('Gemfile') }
            execute(:bundle, :pristine)
          else
            raise Capistrano::ValidationError,
              "Unable to find #{current_path}/.bundle/config, won't run bundle pristine."
          end
        end
      end
    end

    desc 'Set the old ruby version before the change and invoke bundle pristine.'
    task :broken_gems_warning do
      on roles fetch(:rbenv_roles, :all) do |host|
        if fetch(:ruby_modified, false)
          warn('Deploy failed and the ruby version has been modified in this deploy.')
          warn('If this was a minor ruby version upgrade your running application may run into issues with native gem extensions.')
          warn("If your deploy failed before deploy:symlink:release you may run bundle exec 'cap #{fetch(:stage)} opscomplete:ruby:reset'.")
          warn('Please refer https://makandracards.com/makandra/477884-bundler-in-deploy-mode-shares-gems-between-patch-level-ruby-versions')
        else
          debug("#{host}: Ruby not modified in current deploy.")
        end
      end
    end
  end
end
