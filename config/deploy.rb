set :application,         "voicestatus"
set :repository,          "git@github.com:zlu/voicestatus.git"
set :user,                "teresa"
set :password,            "orangesf"
set :deploy_to,           "/vol/data/#{application}"
set :scm,                 :git
set :use_sudo,            false

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

# =================================================================================================
# ROLES
# =================================================================================================
# You can define any number of roles, each of which contains any number of machines. Roles might
# include such things as :web, or :app, or :db, defining what the purpose of each machine is. You
# can also specify options that can be used to single out a specific subset of boxes in a
# particular role, like :primary => true.

task :production do
  role :app, "174.129.215.197"

  set :rails_env, "production"
end

namespace :deploy do

  task :finalize_update do
     run "chmod -R g+w #{release_path}"
     run "rm -rf #{release_path}/log && ln -s #{deploy_to}/shared/log #{release_path}/log"
     run "ln -nfs /vol/data/voicestatus/shared/config/startup.rb #{latest_release}/config/"
  end

  task :restart, :roles => :app do
    run "#{deploy_to}/shared/system/stop"
    run "#{deploy_to}/shared/system/start"
  end

end