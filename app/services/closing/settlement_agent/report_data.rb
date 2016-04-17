module Closing::SettlementAgent
  class ReportData
    
    def self.get_monthly_audits(start_date, end_date)
      @monthly_audits = []
      @monthly_audits << Loan.funded.funded_between(start_date, end_date).joins(:settlement_agent_audits).where{loan_num == settlement_agent_audits.loan_id}.map {|loan| loan.settlement_agent_audits.last unless loan.settlement_agent_audits.nil?}.compact.uniq
      @monthly_audits << Loan.funded.funded_between(start_date, end_date).joins(:settlement_agent_trid_audits).where{loan_num == settlement_agent_trid_audits.loan_id}.map {|loan| loan.settlement_agent_trid_audits.last unless loan.settlement_agent_trid_audits.nil?}.compact.uniq
      @monthly_audits.flatten
    end

    def self.monthly_audits(start_date, end_date, options = {})
      @params = options[:params]
      loans = Loan.funded.funded_between(start_date, end_date)
      if @params[:report_type] == "trid"
        loans = loans.joins(:settlement_agent_trid_audits).where{loan_num == settlement_agent_trid_audits.loan_id}.includes(:loan_general, :last_settlement_agent_trid_audit, :account_info).uniq
      else
        loans = loans.joins(:settlement_agent_audits).where{loan_num == settlement_agent_audits.loan_id}.includes(:loan_general, :last_settlement_agent_audit, :account_info).uniq
      end

      if !@params[:area_manager].in?(["null", "undefined", nil])
        loans = loans.for_area_manager(@params[:area_manager])
      end
      if !@params[:loan_officer].in?(["null", "undefined", nil])
        loans = loans.for_loan_officer(@params[:loan_officer])
      end
      if !@params[:branch_manager].in?(["null", "undefined", nil])
        loans = loans.for_branch_manager(@params[:branch_manager])
      end

      @settlement_agent = @params[:settlement_agent].in?(["null", "undefined"]) ? nil : @params[:settlement_agent] 
      @escrow_agent = @params[:escrow_agent_id].in?(["null", "undefined"]) ? nil : @params[:escrow_agent_id]
      if @params[:report_type] == "trid"
        @monthly_audits = loans.map{|loan| loan.last_settlement_agent_trid_audit}
      else
        @monthly_audits = loans.map{|loan| loan.last_settlement_agent_audit}
      end

      @monthly_audits = @monthly_audits.select{|audit| audit.settlement_agent == @settlement_agent} unless @settlement_agent.nil?
      @monthly_audits = @monthly_audits.select{|audit| audit.escrow_agent_id == @escrow_agent.to_i } unless @escrow_agent.nil?
      @monthly_audits.compact.sort_by{|item| [item['settlement_agent'].to_s.downcase ]}

    end

    def self.get_month_to_month_comparison year
      start_date = Date.new(year,1,1)
      end_date = Date.new(year,12,30)

      @monthly_audits = SettlementAgentMonthlyCalculation.where(:month => start_date..end_date)
      @months = @monthly_audits.pluck(:month).uniq
      @comparision_report = []

      @monthly_audits.each do |audit|
        @report = @comparision_report.find {|report| ((report[:escrow_agent_id] == audit.escrow_agent_id) if audit.escrow_agent_id) || ((report[:settlement_agent] == audit.settlement_agent) if audit.settlement_agent)}
        if @report.nil?
          @report = { escrow_agent_id: audit.escrow_agent_id, settlement_agent: audit.settlement_agent, :YTD_Total_Loans_Funded => 0, :'YTD_Total_Defect_Percentage_%' => 0, :'YTD_Total_HUD/CD_Review_Percentage_%' => 0} 
          @report[:escrow_agent_name] = EscrowAgent.find(audit.escrow_agent_id).name rescue nil
          @report[:monthly_report] = []
          @months.each do |month|
            @array = {:"#{month.strftime("%B")}_Loans_Funded" => 0, :"#{month.strftime("%B")}_Total_Defect_Percentage_%" => 0, :"#{month.strftime("%B")}_Total_HUD/CD_Review_Percentage_%" => 0}
            @report[:monthly_report] << @array
          end
          @report[:hud_avg_count] = 0
          @report[:defect_avg_count] = 0
          @comparision_report << @report
        end
        
        @rep = @report[:monthly_report].select {|rep| rep[:"#{audit.month.strftime("%B")}_Loans_Funded"]}
        @rep.first[:"#{audit.month.strftime("%B")}_Loans_Funded"] = audit.loans_funded

        @rep.first[:"#{audit.month.strftime("%B")}_Total_Defect_Percentage_%"] = ((audit.hud_review + audit.other_error_count) == 0 ) ? 0 : (( audit.loans_funded.to_f / (audit.hud_review + audit.other_error_count).to_f) * 100).round(2)
        @rep.first[:"#{audit.month.strftime("%B")}_Total_HUD/CD_Review_Percentage_%"] = (audit.hud_review == 0) ?  0 : (( audit.loans_funded.to_f / audit.hud_review.to_f) * 100).round(2)

        @report[:YTD_Total_Loans_Funded] += audit.loans_funded
        @report[:'YTD_Total_Defect_Percentage_%'] += @rep.first[:"#{audit.month.strftime("%B")}_Total_Defect_Percentage_%"]
        @report[:'YTD_Total_HUD/CD_Review_Percentage_%'] += @rep.first[:"#{audit.month.strftime("%B")}_Total_HUD/CD_Review_Percentage_%"]
        @report[:hud_avg_count] = @rep.first[:"#{audit.month.strftime("%B")}_Total_Defect_Percentage_%"] == 0 ? @report[:hud_avg_count] : @report[:hud_avg_count] + 1
        @report[:defect_avg_count] = @rep.first[:"#{audit.month.strftime("%B")}_Total_HUD/CD_Review_Percentage_%"] == 0 ? @report[:defect_avg_count] : @report[:defect_avg_count] + 1
        
      end
      @comparision_report.each do |report|
        report[:'YTD_Total_Defect_Percentage_%'] = report[:'YTD_Total_Defect_Percentage_%'] / report[:defect_avg_count] if report[:defect_avg_count] != 0
        report[:'YTD_Total_HUD/CD_Review_Percentage_%'] = report[:'YTD_Total_HUD/CD_Review_Percentage_%'] / report[:hud_avg_count] if report[:hud_avg_count] != 0
      end
      @comparision_report
    end

  end
end