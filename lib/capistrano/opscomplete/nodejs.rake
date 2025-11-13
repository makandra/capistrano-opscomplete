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
        unless capture(:nodejs_get_version, release_path) == app_nodejs_version
          validation_error!("#{host}: Node.js version is not set according to application\'s .node-version or .nvmrc file. Use cap opscomplete:nodejs:ensure.")
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
          validation_error!("#{host}: Managed Node.js environment! Won't do any changes to Node.js version.")
        end
        if nodejs_installed_versions.include?(app_nodejs_version)
          info("#{host}: Node.js #{app_nodejs_version} is installed.")
        elsif nodejs_installable_versions.include?(app_nodejs_version)
          info("#{host}: Configured Node.js version is not installed, but available for installation.")
          with tmpdir: fetch(:tmp_dir) do
            execute(:nodejs_install_version, "'#{app_nodejs_version}'")
          end
        else
          error("#{host}: Check if the configured Node.js version: #{app_nodejs_version} is not an installable version")
          info("These are the ten latest versions:")
          info(nodejs_installable_versions.slice(-10,10).join(', '))

          validation_error!("#{host}: Configured Node.js version: #{app_nodejs_version} is not installable.")
        end
        execute(:nodejs_set_version, "'#{app_nodejs_version}'")
        unless app_corepack_version.nil?
          execute(:nodejs_install_corepack_version, "'#{app_corepack_version}'")
        end
      end
    end
  end
end
