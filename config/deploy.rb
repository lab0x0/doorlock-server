# config Capistrano

require 'dotenv'

Dotenv.load

if fetch(:stage) == :production
  set :application, ENV["NAME"]
end

set :user, ENV["SERVER_USER"] 
set :repo_url, ENV["GIT_URL"] 

set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

set :ssh_options, {
  forward_agent: true
}

set :log_level, :debug
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env config/puma/production.rb db/production.sqlite3}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets}

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  desc 'Start application'
  task :start do
    on roles(:app) do
      invoke 'puma:start'
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:app) do
      invoke 'puma:stop'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:stop'
    end

    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:start'
    end
  end


  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do

    end
  end


  task :finishing do
    invoke 'deploy:cleanup'
  end

  after :finishing, :cleanup

  desc 'Clean up old releases'
  task :cleanup do
    on release_roles :all do |host|
      releases = capture(:ls, '-x', releases_path).split
      if releases.count >= fetch(:keep_releases)
        info t(:keeping_releases, host: host.to_s, keep_releases: fetch(:keep_releases), releases: releases.count)
        directories = (releases - releases.last(fetch(:keep_releases)))
        if directories.any?
          directories_str = directories.map do |release|
            releases_path.join(release)
          end.join(" ")
          execute :rm, '-rf', directories_str
        else
          info t(:no_old_releases, host: host.to_s, keep_releases: fetch(:keep_releases))
        end
      end
    end
  end

end
