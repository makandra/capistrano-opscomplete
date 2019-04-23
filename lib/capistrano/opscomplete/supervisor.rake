# vim: filetype=ruby
namespace :opscomplete do
  namespace :supervisor do
    desc '(Re-)Generate the supervisor configuration (e.g. for supervisord).'
    task :gen_config do
      on roles :web do
        within release_path do
          execute :supervisor_gen_config
        end
      end
    end

    desc 'Reread the supervisor configuration and (re)start all Procfile processes'
    task :restart_procs do
      on roles :web do
        within release_path do
          execute :supervisor_restart_procs
        end
      end
    end

    desc 'Stop all Procfile processes in case you want to them to be stopped while your deployment runs'
    task :stop_procs do
      on roles :web do
        within release_path do
          execute :supervisor_stop_procs
        end
      end
    end
  end
end
