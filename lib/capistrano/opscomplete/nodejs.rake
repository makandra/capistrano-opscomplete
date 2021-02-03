# vim: filetype=ruby
require 'capistrano/dsl/opscomplete'

namespace :opscomplete do
  include Capistrano::DSL::Opscomplete
  # desc 'Validate opscomplete specific configuration'
  task :validate do
    invoke('opscomplete:nodejs:check')
  end

  namespace :nodejs do
    desc 'Check if nodejs version is set according to application\'s .node-version or .nvmrc (in this order).'
    task :check do
      on roles fetch(:nodejs_roles, :all) do |host|
        warn("#{host}: Managed Node.js environment! Won't do any changes to nodejs version.") if managed_nodejs?
        unless capture(:nodejs_current_version) == app_nodejs_version
          raise Capistrano::ValidationError,
                "#{host}: Node.js version is not set according to application\'s .node-version or .nvmrc file. Use cap opscomplete:nodejs:ensure."
        end
        info("#{host}: Node.js #{app_nodejs_version} is installed.")
      end
    end

    desc 'Update Node.js version management tool'
    task :update_nodejs_build do
      on roles fetch(:nodejs_roles, :all) do
        execute :nodejs_update_management_tool
      end
    end

    desc 'Install and configure NodeJS according to applications .nvmrc, .node-version or .tool-versions.'
    task :ensure do
      invoke('opscomplete:nodejs:update_nodejs_build')
      on roles fetch(:nodejs_roles, :all) do |host|
        if managed_nodejs?
          raise Capistrano::ValidationError, "#{host}: Managed Node.js environment! Won't do any changes to Node.js version."
        end
        if nodejs_installed_versions.include?(app_nodejs_version)
          info("#{host}: Node.js #{app_nodejs_version} is installed.")
        elsif nodejs_installable_versions.include?(app_nodejs_version)
          info("#{host}: Configured Node.js version is not installed, but available for installation.")
          with tmpdir: fetch(:tmp_dir) do
            execute(:nodejs_install_version, "'#{app_nodejs_version}'")
          end
        else
          info("#{host}: Check if the configured Node.js version is part of the installable versions")
          execute :nodejs_installable_versions
          raise Capistrano::ValidationError,
                "#{host}: Configured Node.js version is neither installed nor installable."
        end
        execute(:nodejs_set_version, "'#{app_nodejs_version}'")
      end
    end
  end
end
