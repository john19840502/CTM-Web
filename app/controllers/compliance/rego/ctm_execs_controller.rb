class Compliance::Rego::CtmExecsController < RestrictedAccessController
  load_and_authorize_resource  class: CtmExecs



  active_scaffold :ctm_execs do |config|
    config.label = 'CT Executives, Directors, and Related Parties'

    config.list.columns = [:id, :first_name, :last_name, :position]
    config.list.sorting = [{ :last_name => :asc }]
    config.create.columns = [:first_name, :last_name, :position]
    config.update.columns = [:first_name, :last_name, :position]

    config.actions.exclude :show
    config.create.link.ignore_method = :hide_create?

  end # active_scaffold

  # def list_authorized?
  #   current_user.is_compliance? || current_user.is_risk_management?
  # end

  # def create_authorized? 
  #   current_user.is_risk_management?
  # end

  # def update_authorized? (record = nil)
  #   current_user.is_risk_management?
  # end

  # def delete_authorized? (record = nil)
  #   current_user.is_risk_management?
  # end

  def hide_create?(record = nil)
    return true unless can? :manage, CtmExecs
  end
end
 
