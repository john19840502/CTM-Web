source 'http://rubygems.org'
ruby '2.3.0'

gem 'rails', '4.1.13'
gem 'haml', '3.1.7'
gem 'haml-rails'

# # CTM Gems
gem 'ctmroles-client', path: "../ctmroles-client"
gem 'ctmcalc-client', path: "../ctmcalc-client"
gem 'ctmdecisionator-client', path: "../ctmdecisionator-client"
gem 'job_status', path: "../custom_gems/job_status"
gem 'shared_ctmweb_utils', path: "../custom_gems/shared_ctmweb_utils"
gem 'analytics_client', path: "../analytics_client"

# active_scaffold has to come *before* jquery-ui-rails in this file, or the wrong version of 
# jquery-ui.css gets delivered to the browser.  This is because AS bundles an old version of 
# jquery-ui.css, and if AS ends up before jqUI in the asset load path list, the version from AS
# gets sent to the browser.  Putting AS before jqui here seems to make it come *after* jqui in the 
# assets load path at the moment, but I really do not understand why.  Asset load path sorting is 
# deeply mysterious.  -- Greg, 2014-10-21
gem 'active_scaffold' #, '3.2.16'
# gem 'active_scaffold_sortable', '3.1.2'
 
# CSS/JS Framework
gem 'jquery-rails', '3.1.2'
gem 'jquery-ui-rails'
gem 'therubyracer'  # , '0.12.1'
gem 'less-rails', git: 'git://github.com/metaskills/less-rails.git'
gem 'twitter-bootstrap-rails', '2.2.8'
gem 'jquery-tablesorter' #, '1.0.5'
gem 'jquery-datatables-rails'   #, '1.11.1'
gem 'underscore-rails'

# gem 'best_in_place'
gem 'best_in_place', git: 'git://github.com/bernat/best_in_place.git'
 
# Database interaction
gem 'activerecord-sqlserver-adapter'#, '3.2.9'
gem 'tiny_tds', '~> 0.7.0'
gem "mongoid" #, '~> 3.0.0'
gem 'activerecord-session_store'

gem 'protected_attributes'

# Tagging
# This is used for navigational contexts, but is globally available
gem 'acts-as-taggable-on'  #, '~> 2.3.1'

# Allow better conditionals in activerecord, like OR or gt lt
gem "squeel" #, git: "git@github.com:activerecord-hackery/squeel.git"

# DB Seed Isolation
gem "seedbed"
 
# # Route Info
# gem 'sextant', '0.1.3'
 
# DateTime validation
gem 'jc-validates_timeliness' #, '3.0.14'
gem 'american_date'  #, '1.0.0' # used to auto parse mm/dd/yyyy formats into proper format
gem 'business_time'#, '0.7.2'
gem 'holidays'

# gem for validating zipcode
gem 'validates_as_postal_code'

gem 'chronic' #, '0.6.7'

# # Fixed-width file manipulation
# gem 'slither', '0.99.4'
# 
# # Open DBF Files ( dBase, xBase, Clipper and FoxPro)
# gem 'dbf', '2.0.1'
# 

# Menu system
# simple-navigation 4.0 totally breaks our (awful) menu system, so have to specify a pre-4.0 version
gem 'simple-navigation', '3.13.0'

# PDF Creation
# Note - requires wkhtmltopdf utility
gem 'wicked_pdf'  #, '0.7.7'

# # Textile markup
# gem 'RedCloth', '4.2.9'

# Security/RBAC
gem 'cancancan'
 
# Single sign-on
# rubycas-client has to come from git for rails 4.1, see https://github.com/rubycas/rubycas-client-rails/issues/27
gem 'rubycas-client', :git => 'git://github.com/rubycas/rubycas-client.git', branch: 'master'

gem 'fiserv', path: "../fiserv"
 
# Hierarchy management
gem 'awesome_nested_set'  #, '1.7.1'
gem 'acts_as_tree'  #, '1.1.0'
gem 'acts_as_list'  #, '0.1.8'


# State Machine
gem 'aasm'  #, '3.0.9'
 
# Excel exporting
gem 'spreadsheet'  # , '0.7.3'
gem 'write_xlsx', git: 'git://github.com/jonathonjones/write_xlsx.git'
gem 'active_scaffold_export'  #, '3.2.2'
# gem 'fastercsv', '1.5.5'
gem 'roo'

# rubyzip is up to 1.1.6 or whatever now, but 1.0 introduced breaking 
# changes.  Our old, hacked version of write_xlsx relies on the old version of 
# rubyzip, so until we upgrade to a modern write_xlsx, we have to keep rubyzip 
# at an older version.  
gem 'rubyzip', '< 1.0.0'
 
# Pagination Gem
gem 'kaminari' #, '0.14.1'
gem 'bootstrap_kaminari'
 
# Attachments
gem 'paperclip'#, '2.8.0'

# String matching
gem 'fuzzy-string-match', '0.9.4'

# nokogiri needs this in order to build local extensions on some systems.  
gem 'mini_portile2', '~> 2.0.0.rc2'

# # XML/HTML/XPath parsing
gem 'nokogiri'
 
# Allows you to declare default values in the model instead of migration
gem 'default_value_for' #, '2.0.1'
 
gem 'net-sftp'
 
gem 'sass-rails',   '~> 4.0.3'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier',     '>= 1.3.0'
 
# # To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '3.0.1'
# 
# Batch processing infrastructure
#gem 'delayed_job'#, '3.0.3'
gem 'delayed_job_active_record'#, '0.3.3'
gem 'delayed_job_web'
gem 'daemons'
# 
# # Cron processing infrastructure
# gem 'whenever', '0.7.3', :require => false
# 
# Error catching tool
gem 'airbrake'#, '3.1.9'
# gem 'girl_friday' #airbrake wants this
# 
# gem 'audited-activerecord', '3.0.0'
 
gem 'tss', :path => "../tss"

# gem 'colored'
gem 'angularjs-rails'
gem 'angular-rails-templates'
gem 'jbuilder', '~> 2.0'
gem 'flowdock'
gem "jasmine", github: "pivotal/jasmine-gem"

gem 'angular-ui-bootstrap-rails'
gem 'pickadate-rails'
gem "highcharts-rails", "~> 3.0.0"
gem "font-awesome-rails"

group :test, :development do
  gem 'dotenv'
  gem 'spring-commands-rspec'
  gem 'fuubar'# , '1.1.0'
#   gem 'randumb', '0.3.0' # Allows us to pick a random member of an ActiveRecord relation
# 
  gem 'rspec-rails'
  gem 'rspec-its'
#   gem 'guard-rspec', '2.0.0'
#   gem 'fivemat', '1.1.0'
end

group :test do
#   # Pretty printed test output
#   gem 'turn', '0.9.6', :require => false
# 
  gem 'capybara' #allows things like "should have_selector"
 
  gem 'factory_girl_rails'  #, '4.1.0'
  gem 'simplecov', '0.7.1', :require => false
  gem 'simplecov-rcov'
#   gem 'sexp_processor', '3.2.0' #Wrong requires this incorrectly, so we have to specify it here
  gem 'wrong'  #, '>= 0.6.2'
#   gem 'shoulda-matchers'
#   gem 'libxml-ruby', '2.4.0'
#   # formatting for jenkins
  gem 'yarjuf', git: 'git@github.com:covaithe/yarjuf.git'

  #yarjuf needs this
  gem 'rspec-legacy_formatters'  
  
  gem 'shared_test_utils', path: '../custom_gems/shared_test_utils'
  # gem 'pry'
  # gem 'pry-debugger'
end
 
group :development, :test do
  gem 'pry-byebug'
  gem 'pry-remote' #, '0.1.7'
end

group :development do
#   gem 'quiet_assets', '1.0.1'
#   gem 'thin', '1.5.0'
# 
#   gem 'bullet', '4.2.0'
#   gem 'letter_opener' , '1.1.0'
  gem 'better_errors', '1.1.0'
  gem 'binding_of_caller'
  gem 'sinatra'
  gem 'foreman'

  #This can make very nice formatting in your irb if you set it up
  # gem 'awesome_print'
end
# gem 'rack-mini-profiler'
