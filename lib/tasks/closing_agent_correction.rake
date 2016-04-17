namespace :cac  do
  desc "To correct the old settlement agent data"
  task :closing_agent_correction => :environment do
    puts 'Starting to save data...'
    ClosingAgentCorrection.update_data
    puts 'Completed.'
  end
end