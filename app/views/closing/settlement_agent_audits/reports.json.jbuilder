if params[:report_type] == 'trid'
	json.partial! 'trid_audits', monthly_audits: @monthly_audits
else
	json.partial! 'pre_trid_audits', monthly_audits: @monthly_audits
end

json.month @start_date.strftime("%B")
json.year @start_date.strftime("%Y")

json.start_date @start_date
json.end_date @end_date

json.settlement_agents(@monthly_audits) do |agent|
	json.name agent.settlement_agent unless agent.settlement_agent.nil?
end

json.escrow_agents(@monthly_audits) do |agent|
	json.(agent.escrow_agent, :id, :name) rescue nil
end

json.area_managers(@monthly_audits) do |agent|
	json.name agent.loan.area_manager
end

json.loan_officers(@monthly_audits) do |agent|
	json.id agent.loan_officer_identifier
	json.name agent.loan_officer
end

json.branch_managers(@monthly_audits) do |agent|
	if !agent.branch_manager.nil?
		json.id agent.loan.loan_general.branch.institution_number rescue nil
		json.name agent.branch_manager || nil
	end
end