begin
  require 'flowdock'
  @flow = Flowdock::Flow.new(:api_token => "0dbb081b577dd21ff99bd91554190d28", :external_user_name => "Deployer")
  @tags = [Date.today.strftime('%m-%d-%Y')]
rescue Exception => e
  puts e.inspect
  puts "For notifications gem install flowdock."
end

namespace :deploy do
  desc "Deploy QA"
  task :qa => :environment do
    cmds = [
      'reset_git',
      'git_rebase',
      'bundle_install',
      'tss_migrations',
      'run_migrations',
      'db_seeds',
      'precompile_assets',
      'update_crontab',
      'restart_passenger',
      'restart_dj'
    ]
    puts "Running deployment for #{Rails.env}".yellow
    send_to_flowdock("CTMWEB", "Deployment for #{Rails.env.upcase} started.", @tags)
    cmds.each do |t|
      Rake::Task["deploy:#{t}"].invoke
    end
    send_to_flowdock("CTMWEB", "Deployment for #{Rails.env.upcase} completed.", @tags)
  end

  #desc "Reset local directory."
  task :reset_git do
    print "Resetting local directory...."
    run_cmd 'git checkout -- .'
  end

  #desc "Run bundle install"
  task :bundle_install do
    print "Running Bundle Install...."
    run_cmd "bundle install --deployment"
  end

  #desc "Rebase directory"
  task :git_rebase do
    print "Rebasing directory....."
    run_cmd 'git pull --rebase'
  end

  #desc "Copy TSS Migrations"
  task :tss_migrations do
    print "Installing TSS migrations...."
    run_cmd "rake tss_engine:install:migrations"
  end

  #desc "Run Migrations a.k.a. rake db:ctm:update_database"
  task :run_migrations do
    print "Running migrations...."
    run_cmd "rake db:ctm:update_database"
  end

  #desc "Seed database a.k.a rake db:seed"
  task :db_seeds do
    print "Seeding database...."
    run_cmd "rake db:seed"
  end

  task :precompile_assets do
    print "Pre-Compiling Assets...."
    run_cmd "rake assets:precompile"
  end

  task :update_crontab do
    print "Updating crontab...."
    run_cmd "whenever --update-crontab -s 'environment=qa'"
  end

  task :restart_passenger do
    print "Restarting Passenger...."
    run_cmd "touch #{Rails.root}/tmp/restart.txt"
  end

  task :restart_dj do
    print "Restarting Delayed Job...."
    run_cmd "script/delayed_job restart"
  end
end


def send_to_flowdock(subject, message, tags)
  @flow.push_to_team_inbox subject: subject , tags: tags, source: 'deploy',
    content: message, from: {address: 'ctmlabs@gmail.com', name: 'CTM Deployer'}
end

# Run the specified command in the rails root directory.
def run_cmd(cmd)
  Dir.chdir(Rails.root) {
    #@output = `cd #{CTMWEB_PATH} && #{cmd} 2>&1`
    cmd = "#{cmd}"
    @output = `#{cmd}`
  }
  result = $?.success?
  if result
    print "OK\n".green
  else
    print "ERROR\n".red
    puts "#{@output.to_s.red}"
    send_to_flowdock("CTMWEB", "Deployment for #{Rails.env.upcase} failed. (CMD: #{cmd})", @tags)
    abort "Deployment Halted.".red
  end
end

