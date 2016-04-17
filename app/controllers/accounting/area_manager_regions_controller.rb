class Accounting::AreaManagerRegionsController < RestrictedAccessController
    
  load_and_authorize_resource


  active_scaffold :area_manager_region do |config|

    config.columns = [:created_at,
                      :area_manager]

    config.actions.exclude :update
    config.actions.exclude :show

    config.label = 'Assigned Area Managers'
    config.create.label = 'Assign Area Manager'
    config.create.link.label = 'Assign Area Manager'

  end

  # def list_authorized?
  #   current_user.is_sales?
  # end

  # def delete_authorized?(report = nil)
  #   current_user.is_sales?
  # end

  # def create_authorized?
  #   current_user.is_sales?
  # end
end
