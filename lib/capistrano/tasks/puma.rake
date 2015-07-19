# Взято тут https://gist.github.com/alepore/8083925

commands = %w(start stop restart phased-restart status stats halt)

namespace :puma do
  desc 'Puma web server Start'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        execute :bundle, "exec puma -C #{config_file}"
      end
    end
  end

  (commands - ['start']).each do |command|
    desc "Puma web server #{command.capitalize}"
    task command.to_sym do
      on roles(:app), in: :sequence, wait: 5 do
        within current_path do
          if command =~ /restart$/
            if !test("[ -f #{pid_path} ]")
              #Rake::Task['deploy:start'].invoke
              #Rake::Task['puma:start'].invoke
              execute :bundle, "exec pumactl -F #{config_file} start"
            else
              execute :bundle, "exec pumactl -F #{config_file} stop; echo \"trying to stop puma\""
              execute :bundle, "exec pumactl -F #{config_file} start"
            end
          else
            execute :bundle, "exec pumactl -F #{config_file} #{command}"
          end
        end
      end
    end
  end

  # RVM integration
  if Gem::Specification::find_all_by_name('capistrano-rvm').any?
    commands.each do |command|
      before command.to_sym, 'rvm:hook'
    end
  end
end

def config_file
  "./config/puma/#{fetch(:stage)}.rb"
end

def state_path
  configuration.options[:state]
end

def pid_path
  configuration.options[:pidfile]
end

def configuration
  require 'puma/configuration'

  config = Puma::Configuration.new(config_file: config_file)
  config.load
  config
end

