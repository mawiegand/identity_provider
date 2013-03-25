role :web, "backup-round2.wack-a-doo.de"
role :app, "backup-round2.wack-a-doo.de"
role :db,  "backup-round2.wack-a-doo.de", :primary => true        # This is where Rails migrations will run

set :port, 5775

set :rails_env, 'round2'
set :branch,    "backup-round2"

set :deploy_to,  '/var/www/identity_provider_round2'