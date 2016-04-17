# We have to make sure the database doesn't get cleared if someone types "rake test"
Rake::Task["db:test:load"].clear
Rake::Task["db:test:prepare"].clear
Rake::Task["db:test:clone"].clear
