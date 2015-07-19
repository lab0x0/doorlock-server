#!/usr/bin/env puma

directory '/home/#{Rails.application.secrets.server_user}/apps/#{Rails.application.secrets.name}/current'
environment 'production'
daemonize true
pidfile "/home/#{Rails.application.secrets.server_user}/apps/#{Rails.application.secrets.name}/shared/tmp/pids/puma.pid"
state_path "/home/#{Rails.application.secrets.server_user}/apps/#{Rails.application.secrets.name}/shared/tmp/sockets/puma.state"
stdout_redirect '/home/#{Rails.application.secrets.server_user}/apps/#{Rails.application.secrets.name}/shared/log/puma_error.log', '/home/#{Rails.application.secrets.server_user}/apps/#{Rails.application.secrets.name}/shared/log/puma_access.log', true
threads 0,8
bind "unix:///home/#{Rails.application.secrets.server_user}/apps/#{Rails.application.secrets.name}/shared/tmp/sockets/puma.sock"

workers 0
preload_app!
