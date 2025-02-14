# vim: filetype=ruby
namespace :opscomplete do
  namespace :supervisor do
    desc '(Re-)Generate the supervisor configuration (e.g. for supervisord).'
    task :gen_config do
      on roles fetch(:procfile_role, :app) do |host|
        within release_path do
          execute :supervisor_gen_config, host.properties.procfile
        end
      end
    end

    desc 'Remove supervisor configuration and stop all Procfile processes on non :procfile_role servers.'
    task :disable do
      on roles(:all) - roles(fetch(:procfile_role, :app)) do
        within release_path do
          execute :supervisor_disable
        end
      end
    end

    desc 'Reread the supervisor configuration and (re)start all Procfile processes'
    task :restart_procs do
      on roles fetch(:procfile_role, :app) do
        within release_path do
          execute :supervisor_restart_procs
        end
      end
    end

    desc 'Stop all Procfile processes in case you want to them to be stopped while your deployment runs'
    task :stop_procs do
      on roles fetch(:procfile_role, :app) do
        within release_path do
          execute :supervisor_stop_procs
        end
      end
    end

    # Can be used for example to quiet sidekiq with a task like this:
    #
    #     namespace :sidekiq do
    #       desc 'quiet all sidekiq processes so they stop accepting new jobs.'
    #       task :quiet do
    #         on roles :cron do
    #           # The TSTP signal tells sidekiq to quiet all workers.
    #           # see: https://github.com/mperham/sidekiq/wiki/Signals#tstp
    #           invoke('opscomplete:supervisor:signal_procs', 'TSTP', 'sidekiq')
    #         end
    #       end
    #     end
    desc 'Sends the signal (e.g. USR1 or TSTP) to all programs or if specified to program_name.'
    task :signal_procs, :signal, :program_name do |_task_name, args|
      signal = args.fetch(:signal)
      program_name = args.fetch(:program_name, nil)

      on roles fetch(:procfile_role, :app) do
        within release_path do
          if program_name
            execute :supervisor_signal_procs, signal, program_name
          else
            execute :supervisor_signal_procs, signal
          end
        end
      end
    end
  end
end
