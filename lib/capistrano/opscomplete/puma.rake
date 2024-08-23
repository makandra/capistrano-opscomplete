# vim: filetype=ruby
namespace :opscomplete do
  namespace :puma do

    desc 'Reload puma'
    task :reload do
      on roles fetch(:puma_roles, :all) do # by default only the puma role, but if not available on all systems
        execute :puma_reload
      end
    end

    desc 'Restart puma'
    task :restart do
      on roles fetch(:puma_roles, :all) do # by default only the puma role, but if not available on all systems
        execute :puma_restart
      end
    end

  end
end
