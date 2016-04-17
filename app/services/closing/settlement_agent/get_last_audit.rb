module Closing::SettlementAgent
  class GetLastAudit

    def self.call loan
      unless loan.nil?
        @audit_class = loan.trid_loan? ? SettlementAgentTridAudit : SettlementAgentAudit
        @audit_class.where(loan_id: loan.loan_num).last || @audit_class.new({loan_id: loan.loan_num, settlement_agent: loan.loan_general.closing_agents.where{ agent_type == "TitleCompany"}.first.try(:name)}, without_protection: true)
      end
    end

    def self.conclusion loan, audit
      pass_conclusion = {conclusion: "PASS", status: 'pass'}
      fail_conclusion = {conclusion: "FAIL", status: 'fail'}
      if loan.trid_loan?
        if (audit.cd_page1_correct == 'Yes' && audit.cd_page2_correct == 'Yes' && audit.cd_page3_correct == 'Yes' && audit.cd_page4_correct == 'Yes' && audit.cd_page5_correct == 'Yes' && audit.cd_page6_correct == 'Yes')
          @conclusion = pass_conclusion
        else
          @conclusion = fail_conclusion
        end
      else
        if ((audit.agent_page1 == "Yes" ) && (audit.agent_page2 == "Yes" ) && (audit.agent_page3 == "Yes") && (audit.seller_credit_changed == "No" ) && (audit.realtor_credit_changed == "No" ) && (audit.lender_credit_changed == "No" ))
          @conclusion = pass_conclusion
        else
          @conclusion = fail_conclusion
        end
      end
      @conclusion
    end
  end
end