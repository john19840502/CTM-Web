require 'active_support'
require 'active_support/core_ext'

module FakeServices

  module Roles
    class Server < Sinatra::Base
      get "/:id" do
        {
          attributes: 
            {
              login: 'masingh',
              created_at: '2013-02-26T21:11:27Z',
              department_id: '2',
              display_name: 'Hans Masing',
              distinguished_name: 'CN=Hans Masing,OU=OU-CTMUsers,DC=CTMDEV,DC=lab',
              email: 'masingh@CTMDEV.lab',
              first_name: 'Hans',
              id: 80,
              is_active: true,
              job_title_id: 2,
              last_name: 'Masing',
              login: 'masingh',
              updated_at: '2013-03-18T15:19:02Z',
              uuid: 'a6aa2f8f-e8b0-4146-82c0-e7f8513271f4'
            }
        }.to_json
      end

      get "/80/roles.json" do
        ['active', 'admin', 'role_admin'].to_json
      end

      get "/80/groups.json" do
        [
          {
           "distinguished_name" => "CN=ESX Admins,OU=OU-CTBGroups,DC=CTMDEV,DC=lab",
           "name"=>"ESX Admins"
          },
          {
            "distinguished_name"=>"CN=TimeMachineUsers,OU=OU-CTBGroups,DC=CTMDEV,DC=lab",
            "name"=>"TimeMachineUsers"
          }
        ].to_json
      end
    end
  end

  module Decisions
    class Server < Sinatra::Base

      get "/*" do
        {
          "decision_flow" => {
            "fact_types" => [
              {
                "data_type" => "CODE",
                "model_mapping" => "BaseLoanAmount1003",
                "name" => "Base Loan Amount 1003", 
                "permalink" => "base-loan-amount-1003"
              }
            ]
          }
        }.to_json
      end

      post "/*" do
        {"conclusion" => "fake"}.to_json
      end

    end
  end

end
