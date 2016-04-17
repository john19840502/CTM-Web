
json.agents @comparision_report do |audit|
	json.Settlement_Agent_Name audit[:settlement_agent]
	json.Escrow_Agent_Name audit[:escrow_agent_name]

	audit[:monthly_report].each do |rep|
		rep.each do |key, value|
			json.set! key, value
		end
	end
	json.YTD_Total_Loans_Funded audit[:YTD_Total_Loans_Funded]
	json.set! "YTD_Total_Defect_Percentage_%", audit[:'YTD_Total_Defect_Percentage_%']
	json.set! "YTD_Total_HUD/CD_Review_Percentage_%", audit[:'YTD_Total_HUD/CD_Review_Percentage_%']
end
json.year @year
json.current_year Time.now.strftime("%Y")