class StateTitleVendorsController < RestrictedAccessController
  load_and_authorize_resource
    
  active_scaffold :"state_title_vendor" do |config|
    config.actions.exclude :create
    config.actions.exclude :delete
    config.actions.exclude :show
    config.label = "National Title Vendor List by State by Channel"
    config.list.pagination = false
    config.columns[:retail_vendor].clear_link
    config.columns[:retail_vendor].form_ui = :select
    config.columns[:wholesale_vendor].clear_link
    config.columns[:wholesale_vendor].form_ui = :select
    config.search.link.weight = -1
  end

end
