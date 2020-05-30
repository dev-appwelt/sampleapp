# config valid for current version and patch releases of Capistrano
lock "~> 3.14.0"

set :application, "sampleapp"
set :repo_url, "git@github.com:dev-appwelt/sampleapp.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to,       "/var/www/deployment/#{fetch(:application)}"

set :stage,           :production
set :deploy_via,      :remote_cache

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

server '167.71.232.212', port: 22, roles: [:web, :app, :db], primary: true
set :user,            'deploy'

# deploy.rb or stage file (staging.rb, production.rb or else)
set :rvm_type, :user                     # Defaults to: :auto
set :rvm_ruby_version, '2.6.5'      # Defaults to: 'default'
set :rvm_custom_path, '/usr/share/rvm/'  # only needed if not detected
set :keep_releases, 0

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/application.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'tmp/download_jobs', 'tmp/download_job_zips', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

 %w[start stop restart].each do |command|
   desc "#{command} unicorn server"
   task "unicorn_#{command}" do
     on roles(:web) do
       as :deploy do
         execute "/etc/init.d/unicorn_#{fetch(:application)} #{command}"
       end
     end
   end
 end

 # after :restart, :clear_cache do
 #   on roles(:web), in: :groups, limit: 3, wait: 10 do
 #     within release_path do
 #     end
 #   end
 # end

 # example: cap qa deploy:invoke task=db:migrate
 desc "Invoke rake task"
 task :invoke do
   on roles(:web) do
     within "#{deploy_to}/current" do
       with rails_env: fetch(:rails_env) do
         execute :rake, ENV['task']
       end
     end
   end
 end
end

after "deploy:finished", 'deploy:unicorn_restart'