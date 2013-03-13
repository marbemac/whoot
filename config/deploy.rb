require 'bundler/capistrano'
#require 'sidekiq/capistrano'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :rails_env, "production"
set :domain, '198.211.110.136'
set :application, 'whoot'
set :repository,  'https://marbemac@github.com/whoot/whoot.git'
set :branch,  'devshop'
set :deploy_to, "/var/www/#{application}"

set :scm, :git
set :scm_verbose, true

# roles (servers)
role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 3
set :user, 'root'

set :bundle_without, [:development, :test]

set :rake, "#{rake} --trace"

set :default_environment, {
    'PATH' => "/usr/local/rvm/gems/ruby-1.9.3-p392/bin:/usr/local/rvm/gems/ruby-1.9.3-p392@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p392/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games",
    'RUBY_VERSION' => 'ruby 1.9.3',
    'GEM_HOME'     => '/usr/local/rvm/gems/ruby-1.9.3-p392@TheWhoot',
    'GEM_PATH'     => '/usr/local/rvm/gems/ruby-1.9.3-p392:/usr/local/rvm/gems/ruby-1.9.3-p392@global:/usr/local/rvm/gems/ruby-1.9.3-p392@TheWhoot',
    'BUNDLE_PATH'  => '/usr/local/rvm/gems/ruby-1.9.3-p392@TheWhoot'  # If you are using bundler.
}

after 'deploy:setup' do
  sudo "chown -R #{user} #{deploy_to} && chmod -R g+s #{deploy_to}"
end

after "deploy:update_code", "deploy:precompile_assets"
after "deploy:update", "foreman:export"
after "deploy:update", "foreman:restart"

namespace :deploy do
  desc "Restart Passenger"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "precompile the assets"
  task :precompile_assets, :roles => :app do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
  end
end

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, :roles => :app do
    run "cd #{release_path} && #{try_sudo} bundle exec foreman export upstart /etc/init -a #{application} -u #{user} -l #{release_path}/log/foreman"
  end

  desc "Start the application services"
  task :start, :roles => :app do
    sudo "start #{application}"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    sudo "stop #{application}"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    run "#{try_sudo} start #{application} || #{try_sudo} restart #{application}"
  end

  desc "Display logs for a certain process - arg example: PROCESS=web-1"
  task :logs, :roles => :app do
    run "cd #{current_path}/log && cat #{ENV["PROCESS"]}.log"
  end
end