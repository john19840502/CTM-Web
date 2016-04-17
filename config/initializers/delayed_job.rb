require 'airbrake_plugin'
Delayed::Worker.plugins << AirbrakePlugin
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 1
