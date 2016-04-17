class Admin::SubdomainsController < RestrictedAccessController
  active_scaffold :subdomain do |config|
    config.list.columns = [:name, :label, :href, :updated_at]
  end
end
