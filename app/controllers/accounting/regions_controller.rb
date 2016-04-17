class Accounting::RegionsController < RestrictedAccessController
    
  load_and_authorize_resource


  active_scaffold :region do |config|

    config.columns = [:name,
                      :area_manager_regions
                     ]

    config.create.columns = [:name]
    config.update.columns = [:name]

    config.actions.exclude :search
    config.actions.exclude :show
    config.actions.exclude :create
    config.actions.exclude :update
    config.actions.exclude :delete

  end

  # def list_authorized?
  #   current_user.is_sales?
  # end
end
