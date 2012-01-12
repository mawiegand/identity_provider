require "bundler/capistrano"

`ssh-add`

default_run_options[:pty] = true                  # problem with ubuntu
set :ssh_options, :forward_agent => true          # ssh forwarding

set :application, "identity provider"
set :repository,  "git@github.com:wackadoo/identity_provider.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/var/www/identity_provider"
set :deplay_via, :remote_cache

role :web, "wackadoo.de"                          # Your HTTP server, Apache/etc
role :app, "wackadoo.de"                          # This may be the same as your `Web` server
role :db,  "wackadoo.de", :primary => true        # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

namespace :deploy do
  desc "Restart Thin"
  task :restart, :roles => :app, :except => { :no_release => true } do
    start
    stop
  end 

  desc "Start Thin"
  task :start do
    run "cd #{current_path}; thin -C config/thin.yml start"
  end 
  
  desc "Stop Thin"
  task :stop do
    run "cd #{current_path}; thin stop"
  end 
end