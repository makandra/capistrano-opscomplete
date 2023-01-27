load File.expand_path('sidekiq.rake', __dir__)

# Update and Restart supervisor config
after 'deploy:starting', 'opscomplete:sidekiq:quiet'
after 'deploy:updating', 'opscomplete:supervisor:gen_config'
after 'deploy:published', 'opscomplete:supervisor:restart_procs'

# Terminate sidekiq quiet processes (new processes get started by supervisor)
after 'deploy:failed', 'opscomplete:sidekiq:term'
