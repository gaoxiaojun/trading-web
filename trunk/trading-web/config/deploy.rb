require 'deprec/recipes'

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

set :domain, "67.207.144.14"
role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "trading_companies"
set :deploy_to, "/var/www/apps/#{application}"

# XXX we may not need this - it doesn't work on windows
set :user, "deploy"
set :repository, "svn+ssh://#{user}@#{domain}#{deploy_to}/repos/trunk"
set :rails_env, "production"

# Automatically symlink these directories from current/public to shared/public.
# set :app_symlinks, %w{photo, document, asset}

# =============================================================================
# SPECIAL OPTIONS
# =============================================================================
# These options allow you to tweak deprec behaviour

# If you do not keep database.yml in source control, set this to false.
# After new code is deployed, deprec will symlink current/config/database.yml 
# to shared/config/database.yml
#
# You can generate shared/config/database.yml with 'cap generate_database_yml'
#
# set :database_yml_in_scm, true

# =============================================================================
# APACHE OPTIONS
# =============================================================================
set :apache_server_name, domain
# set :apache_server_aliases, %w{alias1 alias2}
# set :apache_default_vhost, true # force use of apache_default_vhost_config
# set :apache_default_vhost_conf, "/usr/local/apache2/conf/default.conf"
# set :apache_conf, "/usr/local/apache2/conf/apps/#{application}.conf"
# set :apache_ctl, "/etc/init.d/httpd"
# set :apache_proxy_port, 8000
# set :apache_proxy_servers, 2
# set :apache_proxy_address, "127.0.0.1"
# set :apache_ssl_enabled, false
# set :apache_ssl_ip, "127.0.0.1"
# set :apache_ssl_forward_all, false
# set :apache_ssl_chainfile, false


# =============================================================================
# MONGREL OPTIONS
# =============================================================================
# set :mongrel_servers, apache_proxy_servers
# set :mongrel_port, apache_proxy_port
set :mongrel_address, apache_proxy_address
# set :mongrel_environment, "production"
# set :mongrel_config, "/etc/mongrel_cluster/#{application}.conf"
# set :mongrel_user_prefix,  'mongrel_'
# set :mongrel_user, mongrel_user_prefix + application
# set :mongrel_group_prefix,  'app_'
# set :mongrel_group, mongrel_group_prefix + application

# =============================================================================
# MYSQL OPTIONS
# =============================================================================


# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25



# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

task :deploy_all, :roles => :web do
  cleanup
  svn_upload_data
  disable_web
  memcached_restart
  deploy_with_migrations
  init_index_folder
  change_permissions
  enable_web
  restart_backgroundrb
end

task :deploy_all_with_data, :roles => :web do
  disable_web
  deploy_all
#  init_db
  load_data
  enable_web
end

task :db_migrate, :roles => :db do
  run 'rake db:migrate'
end

class Capistrano::Actor
  def chg_perm path
#    sudo "test -d #{path} || sudo mkdir -p #{path}"
    sudo "chgrp -R #{group} #{path}"
    sudo "chmod -R 7777  #{path}"
  end
end

task :change_permissions, :roles => :web do
  chg_perm "#{current_path}/public/companies"
  chg_perm "#{current_path}/index/production/company"
  chg_perm "#{current_path}/data/last_traded_prices"
  chg_perm "#{current_path}/data/companies"
  chg_perm "#{current_path}/public/companies/verify_log"
end

task :svn_upload_data do
  sudo "svn add #{current_path}/data/* --force"
  shell_command = "svn  commit #{current_path}/data/* -m 'last traded price'"
  send(:sudo, shell_command) do |channel, stream, data|
    logger.info data, channel[:host]
    if data =~ /^deploy\@67\.207\.144\.14\'s password\: /
      channel.send_data "hrabrina\n"
    end
  end
end

desc 'Prepare database'
task :init_db, :roles => :db, :only => { :primary => true } do
  sudo "cd #{deploy_to}/#{current_dir} && " +
    "#{rake} RAILS_ENV=#{rails_env} db:test:prepare" 
end

task :init_index_folder ,  :roles => :web do
  sudo "rm -r #{current_path}/index/production/company"
  sudo "mkdir #{current_path}/index/production/company"
end

task :load_data,  :roles => :db do
  sudo "ruby #{current_path}/script/loader -all local"
end

task :start_backgroundrb,  :roles => :web do
   sudo "/etc/init.d/backgroundRb start"
end

task :stop_backgroundrb , :roles => :app do
  sudo "/etc/init.d/backgroundRb stop"
end

task :restart_backgroundrb,  :roles => :web do
   stop_backgroundrb
   start_backgroundrb
end


 desc "Create asset packages for production" 
 task :after_update_code, :roles => [:web] do
   run <<-EOF
     cd #{release_path} && rake RAILS_ENV=production asset:packager:build_all
   EOF
 end

desc <<DESC
An imaginary backup task. (Execute the 'show_tasks' task to display all
available tasks.)
DESC
task :backup, :roles => :db, :only => { :primary => true } do
  # the on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  on_rollback { delete "/tmp/dump.sql" }

  run "mysqldump -u theuser -p thedatabase > /tmp/dump.sql" do |ch, stream, out|
    ch.send_data "thepassword\n" if out =~ /^Enter password:/
  end
end

# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do
  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  sudo "killall -USR1 dispatch.fcgi"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"
end

# You can use "transaction" to indicate that if any of the tasks within it fail,
# all should be rolled back (for each task that specifies an on_rollback
# handler).

desc "A task demonstrating the use of transactions."
task :long_deploy do
  transaction do
    update_code
    disable_web
    symlink
    migrate
  end

  restart
  enable_web
end

desc "Run a script to prepare mysql for the initial migration"
task :bootstrap_mysql, :roles => :db do
  run "mysql -u root < #{current_path}/db/bootstrap.sql"
end

desc "Run all initial setup tasks"
task :banzai do
  setup
  cold_deploy
  bootstrap_mysql
  migrate
end