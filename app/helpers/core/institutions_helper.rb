module Core::InstitutionsHelper
  def compensation_plans branch
    html = ''
    
    branch.branch_compensations.each do |plan|
      html << link_to_if(can?(:read, BranchCompensation), "#{plan.name} #{plan.termination_date.strftime('%m/%d/%Y') if plan.termination_date.present?}", accounting_branch_compensation_path(plan))
      html << "<br>"
    end

    if can?(:manage, BranchCompensation)
      link = link_to new_accounting_branch_compensation_path(bid: branch.id), class: 'btn btn-mini btn-info' do
                raw "<i class='icon-plus'></i> Add Plan"
              end
      html << link
    end

    html
  end
end