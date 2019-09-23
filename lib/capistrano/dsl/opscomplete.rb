module Capistrano
  module DSL
    # A whole capistrano/rake namespace, for grouping our helpers and tasks
    module Opscomplete
      def managed_ruby?
        test("[ -f #{rbenv_root_path}/.ruby_managed_by_makandra ]")
      end

      def rbenv_ruby_build_path
        "#{rbenv_root_path}/plugins/ruby-build"
      end

      def rbenv_repo_url
        'https://github.com/rbenv/rbenv.git'
      end

      def ruby_build_repo_url
        'https://github.com/rbenv/ruby-build.git'
      end

      def app_ruby_version
        release_ruby_version_file_path = release_path.join('.ruby-version').to_s

        # 1) Get version from capistrano configuration (highest precedence, 'override')
        if fetch(:opscomplete_ruby_version)
          debug("Using version from :opscomplete_ruby_version setting: #{fetch(:opscomplete_ruby_version)}.")
          return fetch(:opscomplete_ruby_version)

        # 2) Get version from .ruby-version in release dir (after deploy:updating, before deploy:updated)
        elsif test("[ -f #{release_ruby_version_file_path} ]")
          debug("Using version from server's release_dir/.ruby-version file: #{capture(:cat, release_ruby_version_file_path)}")
          return capture(:cat, release_ruby_version_file_path)

        # 3) Get version from local checkout/cwd
        elsif File.readable?('.ruby-version')
          debug("Using version from local (cwd) .ruby-version file: #{File.read('.ruby-version').strip}")
          return File.read('.ruby-version').strip

        # FAIL: We have no idea which version to use
        else
          raise Capistrano::ValidationError, 'Could not find application\'s .ruby-version. Consider setting opscomplete_ruby_version.'
        end
      end

      def rbenv_installable_rubies
        rbenv_installable_rubies = capture(:rbenv, :install, '--list').split("\n")
        rbenv_installable_rubies.map!(&:strip)
        rbenv_installable_rubies.delete('Available version:')
        rbenv_installable_rubies
      end

      def rbenv_root_path
        capture(:rbenv, :root)
      end

      def rbenv_installed_rubies
        if test("[ -d #{rbenv_root_path}/versions ]")
          rbenv_installed_rubies = capture(:ls, '-1', "#{rbenv_root_path}/versions").split("\n")
          rbenv_installed_rubies.map!(&:strip)
        else
          warn("Could not look up installed versions from missing '.rbenv/versions' directory. This is probably the first ruby install for this rbenv.")
          []
        end
      end

      def rbenv_exec(*args)
        execute(:rbenv, :exec, *args)
      end

      def gem_installed?(name, version = nil)
        if version
          test(:rbenv, :exec, "gem query --quiet --installed --version '#{version}' --name-matches '^#{name}$'")
        else
          test(:rbenv, :exec, :gem, :query, "--quiet --installed --name-matches ^#{name}$")
        end
      end

      def gem_install(name, version = nil)
        if version
          rbenv_exec('gem install', name, '--no-document', '--version', "'#{version}'")
        else
          rbenv_exec('gem install', name, '--no-document')
        end
      end

      def rubygems_install(version)
        rbenv_exec("gem update --no-document --system '#{version}'")
      end
    end
  end
end
