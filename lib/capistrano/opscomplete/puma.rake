# vim: filetype=ruby
namespace :opscomplete do
  namespace :puma do

    desc 'Reload the systemd puma userunit'
    task :reload do
      on roles fetch(:puma_roles, :all) do # by default only the puma role, but if not available on all systems
        execute :systemctl_user_puma_reload
      end
    end

  end
end
