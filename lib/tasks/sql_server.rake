namespace :db  do
  namespace :ctm do

    desc "Execute SQLServer Scripts"
    task :sqlserver => :environment do
      DatabaseDatamartReadonly.run_sqlserver_scripts
    end

    desc "Execute Master DB SQLServer Scripts"
    task :master_views => :environment do
      Master::Avista::ReadOnly.run_sqlserver_scripts
    end

    desc "Run SQLServer scripts and migrations"
    task :update_database => :environment do
      Rake::Task['db:migrate'].invoke
      Rake::Task['db:ctm:sqlserver'].invoke
      Rake::Task['db:ctm:master_views'].invoke
    end

    desc "Update database, annotations and schema"
    task :update_schema => :environment do
      Rake::Task['db:ctm:update_database'].invoke
      Rake::Task['db:schema:dump'].invoke
      puts "schema updated"
    end
  end #ctm


  desc "Index all date, id and boolean fields"
  task :auto_index => :environment do
    # Not done yet... - Hans
    # The purpose here is to automatically add indices to all of our boolean, id and
    # date columns, since it's easy to miss them in the migrations
  end # auto_index

  namespace :migrate do
    desc "Do all the tss migrations.  If it fails with an error, just move on to the next."
    task :tss => [:environment, "tss_engine:install:migrations"] do
      tss_migrations = Dir["db/migrate/*tss*.rb"].sort
      tss_migrations.each do |migration|
        begin
          version = migration.scan(/\d+/).first
          puts version
          ENV['VERSION'] = "#{version}"
          Rake::Task['db:migrate:up'].reenable
          Rake::Task['db:migrate:up'].invoke
          puts "migration #{migration} succeeded"
        rescue => e
          puts "migration #{migration} failed: #{e.message}"
          next  # omgwtfbbq
        end
      end
    end
  end

end #db

namespace :ctm do
  desc "Prepare test database and run specs"
  task :run_specs do
    sh("rake db:migrate:tss > /dev/null")
    sh("rake db:migrate:tss RAILS_ENV=test > /dev/null")
    sh("rm db/migrate/*.tss_engine.rb")
    sh("rake db:ctm:update_database RAILS_ENV=development skip_on_db_migrate=true > /dev/null")
    sh("rake db:ctm:update_database RAILS_ENV=test skip_on_db_migrate=true > /dev/null")
    sh("bundle exec rspec spec")
  end

  desc "Run specs without updating database"
  task :fast_specs do
    system("bundle exec rspec spec")
  end

  desc "Print out sqlserver scripts without updated database"
  task :print_sqlserver => :environment do
    DatabaseDatamartReadonly.print_sqlserver_scripts
  end
end

