require "bundler/capistrano"

set :stages, %w(production staging_test)
set :default_stage, "production"

require "capistrano/ext/multistage"

`ssh-add`

default_run_options[:pty] = true                  # problem with ubuntu
set :ssh_options, :forward_agent => true          # ssh forwarding
#set :gateway, 'wackadoo.de:5775'
set :port, 5775

set :application, "identity provider"
set :repository,  "git@github.com:wackadoo/identity_provider.git"

set :scm, :git

set :user, "deploy-ip"
set :use_sudo, false

set :deploy_to, "/var/www/identity_provider"
set :deploy_via, :remote_cache

namespace :deploy do
  desc "Restart Thin"
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end 

  desc "Reset DB"
  task :reset do
    run "cd #{current_path}; bundle exec rake RAILS_ENV=\"#{stage}\" db:reset"
    restart
  end

  desc "Start Thin"
  task :start do
    run "cd #{current_path}; bundle exec thin -C config/thin_#{stage}.yml start"
  end 
  
  desc "Stop Thin"
  task :stop do
    run "cd #{current_path}; bundle exec thin -C config/thin_#{stage}.yml stop"
  end
end