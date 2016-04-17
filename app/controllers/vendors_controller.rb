class VendorsController < RestrictedAccessController
  load_and_authorize_resource

  active_scaffold :"vendor" do |config|
    config.actions.exclude :delete
    config.actions.exclude :edit
    config.columns[:retail_states].clear_link
    config.columns[:retail_states].form_ui = :select
    config.columns[:retail_states].options[:label_method] = :state_full_name
    config.columns[:wholesale_states].clear_link
    config.columns[:wholesale_states].form_ui = :select
    config.columns[:wholesale_states].options[:label_method] = :state_full_name
    config.search.link.weight = -2
    config.create.link.weight = -1
  end
  
end
