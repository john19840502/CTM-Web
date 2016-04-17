class SettlementAgentMonthlyCalculation < DatabaseRailway

	def self.create_monthly_calculation_entries
		start_date = Date.today.beginning_of_month - 1.month
		end_date = Date.today.beginning_of_month - 1.day

		@last_month_audits = Closing::SettlementAgent::ReportData.get_monthly_audits(start_date, end_date)
		
		@last_month_audits.each do |audit|
			if !audit.escrow_agent_id.nil? 
				@entry = SettlementAgentMonthlyCalculation.where{(escrow_agent_id == audit.escrow_agent_id) & (month == start_date)}.first_or_initialize
			elsif !audit.settlement_agent.nil?
				@entry = SettlementAgentMonthlyCalculation.where{(settlement_agent == audit.settlement_agent) & (month == start_date)}.first_or_initialize
			else
				next # This will return control to the next object in loop.
			end

			@entry.hud_review += audit.hud_review
			@entry.loans_funded += 1
			@entry.other_error_count += audit.other_occurance_count
			@entry.save
		end
	end
end
