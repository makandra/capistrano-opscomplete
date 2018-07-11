module Capistrano
  module DSL
    # A whole capistrano/rake namespace, for grouping our helpers and tasks
    module Opscomplete
      def managed_ruby
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
        app_ruby_version_file_path = release_path.join('.ruby-version').to_s
        if fetch(:opscomplete_ruby_version)
          warn("Using version from :opscomplete_ruby_version setting: #{fetch(:opscomplete_ruby_version)}.")
          return fetch(:opscomplete_ruby_version)
        elsif test("[ -f #{app_ruby_version_file_path} ]")
          return capture(:cat, app_ruby_version_file_path)
        else
          raise Capistrano::ValidationError, 'Could not find application\'s .ruby-version. Consider setting opscomplete_ruby_version.'
        end
      end

      def rbenv_installable_rubies
        rbenv_installable_rubies = capture(:rbenv, :install, '--list').split("\n")
        rbenv_installable_rubies.map!(&:strip)
        rbenv_installable_rubies.delete("Available version:")
        rbenv_installable_rubies
      end

      def rbenv_root_path
        capture(:rbenv, :root)
      end

      def rbenv_installed_rubies
        rbenv_installed_rubies = capture(:ls, '-1', "#{rbenv_root_path}/versions").split("\n")
        rbenv_installed_rubies.map!(&:strip)
      end
    end
  end
end
