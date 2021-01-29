module Capistrano
  module DSL
    # A whole capistrano/rake namespace, for grouping our helpers and tasks
    module Opscomplete
      def managed_ruby?
        test(:ruby_update_management_tool, 'managed')
      end

      def app_ruby_version
        release_ruby_version_file_path = release_path.join('.ruby-version').to_s

        # 1) Get version from capistrano configuration (highest precedence, 'override')
        if fetch(:opscomplete_ruby_version)
          debug("Using version from :opscomplete_ruby_version setting: #{fetch(:opscomplete_ruby_version)}.")
          fetch(:opscomplete_ruby_version)

        # 2) Get version from .ruby-version in release dir (after deploy:updating, before deploy:updated)
        elsif test("[ -f #{release_ruby_version_file_path} ]")
          debug("Using version from server's release_dir/.ruby-version file: #{capture(:cat, release_ruby_version_file_path)}")
          capture(:cat, release_ruby_version_file_path)

        # 3) Get version from local checkout/cwd
        elsif File.readable?('.ruby-version')
          debug("Using version from local (cwd) .ruby-version file: #{File.read('.ruby-version').strip}")
          File.read('.ruby-version').strip

        # FAIL: We have no idea which version to use
        else
          raise Capistrano::ValidationError, 'Could not find application\'s .ruby-version. Consider setting opscomplete_ruby_version.'
        end
      end

      def app_gemfile_bundled_with_version
        release_gemfile_lock_file_path = release_path.join('Gemfile.lock').to_s

        if test("[ -f #{release_gemfile_lock_file_path} ]")
          debug('found release_dir/Gemfile.lock')

          grep_command = [:grep, '-A', '1', '"BUNDLED WITH"', release_gemfile_lock_file_path]

          if test(*grep_command)
            bundled_with_lines = capture(*grep_command)
            version = bundled_with_lines.split.last
            debug("Using version #{version.inspect} from server's release_dir/Gemfile.lock file.")
            version
          else
            # old bundler versions did not write "BUNDLED WITH"
            debug('Gemfile.lock was found but did not contain "BUNDLED WITH"-section')
          end
        else
          debug('There was no Gemfile.lock to parse the bundler version')
        end
      end

      def ruby_installable_versions
        ruby_installable_versions = capture(:ruby_installable_versions).split("\n")
        ruby_installable_versions.map!(&:strip)
        ruby_installable_versions
      end

      def ruby_installed_versions
        ruby_installed_versions = capture(:ruby_installed_versions).split("\n")
        ruby_installed_versions.map!(&:strip)
        warn('Could not look up installed versions. This is probably the first ruby install.') if ruby_installed_versions.empty?
        ruby_installed_versions
      end

      def gem_installed?(name, version = nil)
        if version
          test(:ruby_installed_gem, name, '--version', "'#{version}'")
        else
          test(:ruby_installed_gem, name)
        end
      end

      def gem_install(name, version = nil, force = false)
        if version
          execute(:ruby_install_gem, name, '--version', "'#{version}'", force ? '--force' : '')
        else
          execute(:ruby_install_gem, name)
        end
      end

      def managed_nodejs?
        test("[ -f ${HOME}/.nodejs_managed_by_makandra ]")
      end

      def app_nodejs_version

        # 1) Get version from capistrano configuration (highest precedence, 'override')
        if fetch(:opscomplete_nodejs_version)
          debug("Using version from :opscomplete_nodejs_version setting: #{fetch(:opscomplete_nodejs_version)}.")
          fetch(:opscomplete_nodejs_version)

        # 2) Get version from version file in release dir (after deploy:updating, before deploy:updated)
        elsif capture(:nodejs_get_version, release_path)
          debug("Using version from server's release_dir/.nvmrc, .node-version or .tool-versions file: #{capture(:nodejs_get_version, release_path)}")
          capture(:nodejs_get_version, release_path)

        else
          raise Capistrano::ValidationError, 'Could not find application\'s Node.js version. Consider setting opscomplete_ruby_version.'
        end
      end

      def nodejs_installable_versions
        nodejs_installable_versions = capture(:nodejs_installable_versions).split("\n")
        nodejs_installable_versions.map!(&:strip)
        nodejs_installable_versions
      end

      def nodejs_installed_versions
        nodejs_installed_versions = capture(:nodejs_installed_versions).split("\n")
        nodejs_installed_versions.map!(&:strip)
      end
    end
  end
end
