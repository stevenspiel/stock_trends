server = YAML.load_file(File.expand_path('../../config/server.yml',__FILE__))
deploy_path = server['deploy_path']
rvm_paths = server['rvm_paths']

set :user, server[:user]
set :rvm_ruby_string, '2.2.2'
set :stages, %w(production)
set :default_stage, :production

task :production => :use_rvm
task(:use_rvm) { require 'rvm1/capistrano3' }

set :application, 'stock_trends'
set :repo_url, 'git@github.com:stevenspiel/stock_trends.git'

set :tmp_dir, "#{deploy_path}/shared/tmp"

set :shared_path, "#{deploy_path}/shared"
set :releases_path, "#{deploy_path}"
set :current_path, "#{deploy_path}"

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "#{deploy_path}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/keys.yml', 'config/secrets.yml', 'config/server.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'public/uploads', 'uploads')

# Default value for default_env is {}
set :default_env, { path: "#{rvm_paths}:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 2

# namespace :deploy do
#   desc 'symlink assets into the current release path'
#   task :configure_shared_assets do
#     on roles(:app) do
#       within "#{shared_path}" do
#         execute "ln -nsf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
#         execute "ln -nsf #{shared_path}/config/server.yml #{release_path}/config/server.yml"
#         execute "ln -nsf #{shared_path}/config/keys.yml #{release_path}/config/keys.yml"
#         execute "ln -nsf #{shared_path}/config/secrets.yml #{release_path}/config/secrets.yml"
#       end
#     end
#   end
# end
# after 'deploy:assets:precompile', 'deploy:configure_shared_assets'

# namespace :bundle do
#   desc 'run bundle install and ensure all gem requirements are met'
#   task :install do
#     on roles(:all) do
#       execute "cd #{current_path} && bundle install"
#     end
#   end
# end
# before 'deploy:assets:precompile', 'bundle:install'