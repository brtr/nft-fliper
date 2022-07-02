# config valid for current version and patch releases of Capistrano
lock "~> 3.17.0"

set :application, "nft-fliper"
set :repo_url, "git@github.com:brtr/nft-fliper.git"

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/deploy/app/nft-fliper"

set :linked_files, fetch(:linked_files, []).push('config/application.yml').push('config/sidekiq.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

# for sidekiq
set :init_system, :systemd
set :bundler_path, "/home/deploy/.rbenv/shims/bundle"
set :sidekiq_config, "#{current_path}/config/sidekiq.yml"
set :sidekiq_roles, :worker
set :sidekiq_default_hooks, false

set :pty, false
set :rails_env, fetch(:staging)
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '3.0.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :bundler_path, "/home/deploy/.rbenv/shims/bundle"
# for assets
set :assets_role, :web
set :keep_assets, 2

namespace :deploy do
  after :publishing, 'sidekiq:fast_restart'
  after :publishing, 'web:restart'
  after :finishing, :cleanup

  before :updated, :compile_assets_locally
  before :updated, :zip_assets_locally
  before :updated, :send_assets_zip
  before :updated, :unzip_assets

  task :compile_assets_locally do
    run_locally do
      with rails_env: fetch(:stage) do
        execute 'bundle exec rails assets:precompile'
      end
    end
  end

  task :zip_assets_locally do
    run_locally do
      execute 'tar -zcvf ./tmp/assets.tar.gz ./public/assets 1> /dev/null'
      execute 'tar -zcvf ./tmp/packs.tar.gz ./public/packs 1> /dev/null'
    end
  end

  task :send_assets_zip do
    on roles(:web) do |_host|
      upload!('./tmp/assets.tar.gz', "#{release_path}/public/")
      upload!('./tmp/packs.tar.gz', "#{release_path}/public/")
    end
  end

  task :unzip_assets do
    on roles(:web) do |_host|
      execute "rm -rf #{release_path}/public/packs/*"
      execute "cd #{release_path}; tar -zxvf #{release_path}/public/assets.tar.gz 1> /dev/null"
      execute "cd #{release_path}; tar -zxvf #{release_path}/public/packs.tar.gz 1> /dev/null"
    end
  end
end

namespace :web do
  task :setup_config do
    on roles(:web) do
      upload_systemd_config('web')
    end
  end

  task :setup_socket do
    on roles(:web) do
      upload_systemd_config('web', 'socket')
      execute :systemctl, "--user", "start", "web-#{fetch(:application)}.socket"
    end
  end

  task :stop do
    on roles(:web) do
      execute :systemctl, "--user", "stop", "web-#{fetch(:application)}.service"
    end
  end

  task :restart do
    on roles(:web) do
      execute :systemctl, "--user", "restart", "web-#{fetch(:application)}.service"
    end
  end
end

namespace :sidekiq do
  desc "Init the systemd config files"
  task :setup_config do
    on roles(:job) do
      set :sidekiq_queues, ["daily_job", "weekly_job"]
      upload_systemd_config('sidekiq')
    end
  end

  task :fast_restart do
    on roles(:job), in: :sequence, wait: 1 do
      execute :systemctl, "--user", "restart", "sidekiq-#{fetch(:application)}.service"
    end
  end

  task :stop_worker do
    on roles(:job), in: :sequence, wait: 1 do
      execute :systemctl, "--user", "stop", "sidekiq-#{fetch(:application)}.service"
    end
  end

  task :uninstall_worker do
    on roles(:job) do
      execute :systemctl, "--user", "disable", "sidekiq-#{fetch(:application)}.service"
      systemd_path = fetch(:service_unit_path, fetch_systemd_unit_path)
      execute :rm, "#{systemd_path}/sidekiq-#{fetch(:application)}.service"
    end
  end
end

def upload_systemd_config(app, type = 'service')
  template = File.read("config/deploy/templates/#{app}.#{type}.capistrano.erb")
  systemd_path = fetch(:service_unit_path, fetch_systemd_unit_path)
  execute :mkdir, "-p", systemd_path
  upload!(
    StringIO.new(ERB.new(template).result(binding)),
    "#{systemd_path}/#{app}-#{fetch(:application)}.#{type}"
  )
  execute :systemctl, "--user", "daemon-reload"
  execute :systemctl, "--user", "enable", "#{app}-#{fetch(:application)}.#{type}"
end

def fetch_systemd_unit_path
  home_dir = capture :pwd
  File.join(home_dir, ".config", "systemd", "user")
end

