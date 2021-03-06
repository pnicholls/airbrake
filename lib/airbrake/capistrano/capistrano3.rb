namespace :airbrake do
  desc "Notify Airbrake of the deploy"
  task :deploy do
    role = roles(:all, select: :primary).first || roles(:all).first
    on role do
      within release_path do
        with rails_env: fetch(:rails_env, fetch(:stage)) do
          environment = fetch(:airbrake_load_environment) ? :environment : nil
          command = <<-CMD
            airbrake:deploy USERNAME=#{Shellwords.shellescape(local_user)} \
                            ENVIRONMENT=#{fetch(:airbrake_env, fetch(:rails_env, fetch(:stage)))} \
                            REVISION=#{fetch(:current_revision)} \
                            REPOSITORY=#{fetch(:repo_url)} \
                            VERSION=#{fetch(:app_version)}
            CMD
          commands = [:bundle, :exec, :rake, environment, command].compact
          execute(*commands)
          info 'Notified Airbrake of the deploy'
        end
      end
    end
  end
end
