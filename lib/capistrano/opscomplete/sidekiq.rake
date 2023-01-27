namespace :opscomplete do
  namespace :sidekiq do

    # The TSTP signal tells sidekiq to quiet all workers.
    # see: https://github.com/mperham/sidekiq/wiki/Signals#tstp
    # invoke('opscomplete:supervisor:signal_procs', 'TSTP', 'sidekiq')
    desc 'quiet all sidekiq processes so they stop accepting new jobs'
    task :quiet do
      on roles fetch(:procfile_role, :app) do
        supervisor_send_signal('TSTP', 'sidekiq')
      rescue SSHKit::Command::Failed => e
        abort(e.message) if supervisor_configured?

        info('This error occurs if no sidekiq is started yet and will be gone on subsequent deploys')
      end
    end

    # The TTIN signal tells sidekiq to print a backtrace for all threads to the logfile.
    # see: https://github.com/mperham/sidekiq/wiki/Signals#ttin
    desc 'print a backtrace for all sidekiq threads to the logfile'
    task :trace do
      on roles fetch(:procfile_role, :app) do
        supervisor_send_signal('TTIN', 'sidekiq')
      end
    end

    # The TERM signal tells sidekiq to kill quiet all processes for the configured timeout
    #  and then kill them.
    # see: https://github.com/mperham/sidekiq/wiki/Signals#term
    desc 'shuts down all sidekiq processes within the configured timeout'
    task :term do
      on roles :cron do
        supervisor_send_signal('TERM', 'sidekiq')
      end
    end

  end
end
