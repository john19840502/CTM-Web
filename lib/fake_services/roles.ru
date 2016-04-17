require 'sinatra'
require File.expand_path(File.join('lib', 'fake_services', 'roles'))

run Rack::URLMap.new ({"/api/users/" => FakeServices::Roles::Server, "/api/flows" => FakeServices::Decisions::Server})
