set :rails_env, :production
set :stage, :production

role :app, 'stevenspiel.com'
role :web, 'stevenspiel.com', :primary => true
role :db, 'stevenspiel.com'
