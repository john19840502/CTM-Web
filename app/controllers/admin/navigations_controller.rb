class Admin::NavigationsController < RestrictedAccessController

  active_scaffold :navigation do |config|
    config.list.label = 'Menu Configurations'
    config.list.columns = [:label, :name, :url, :children, :role_list, :created_at, :updated_at]
    config.create.columns = [:label, :name, :path, :role_list]
    config.update.columns = [:label, :name, :path, :role_list]
    
    config.columns[:path].form_ui = :select
    config.columns[:path].options = {:options => Navigation.routes}

    config.columns[:label].inplace_edit = true

    config.columns[:parent].form_ui = :select
    config.nested.add_link(:children, label: "Children") 
    config.columns[:children].association.reverse = :parent
    config.columns[:children].includes = []
  end

  def conditions_for_collection
    [:parent_id => nil] unless nested? #if params[:adapter].nil?
  end
end
