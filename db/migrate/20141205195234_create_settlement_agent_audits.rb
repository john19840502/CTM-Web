class CreateSettlementAgentAudits < ActiveRecord::Migration
  def up
    create_table :settlement_agent_audits do |t|
    	t.integer			:loan_general_id
    	t.string			:settlement_agent_id
    	t.integer			:escrow_agent_id
    	t.string			:agent_page1
    	t.integer			:agent_page1_occurance, :default => 0
    	t.string			:agent_page2
    	t.integer			:agent_page2_occurance, :default => 0
    	t.string			:agent_page3
    	t.integer			:agent_page3_occurance, :default => 0
    	t.string			:seller_credit_changed
    	t.integer			:seller_credit_changed_occurance, :default => 0
    	t.string			:realtor_credit_changed
    	t.integer			:realtor_credit_changed_occurance, :default => 0
    	t.string			:lender_credit_changed
    	t.integer			:lender_credit_changed_occurance, :default => 0
    	t.string			:fee_increase, :default => "No"
    	t.integer			:fee_increase_occurance, :default => 0
    	t.string			:fee_decrease, :default => "No"
    	t.integer			:fee_decrease_occurance, :default => 0
    	t.string			:added_apr_fees, :default => "No"
    	t.integer			:added_apr_fees_occurance, :default => 0
    	t.string			:changed_closing_docs,:default => "No"
    	t.integer			:changed_closing_docs_occurance, :default => 0
    	t.string			:changed_legal_docs, :default => "No"
    	t.integer			:changed_legal_docs_occurance, :default => 0
    	t.string			:changed_power_of_attorney, :default => "No"
    	t.integer			:changed_power_of_attorney_occurance, :default => 0
    	t.string			:changed_doc_for_trust, :default => "No"
    	t.integer			:changed_doc_for_trust_occurance, :default => 0
    	t.string			:incorrectly_date_docs, :default => "No"
    	t.integer			:incorrectly_date_docs_occurance, :default => 0
    	t.string			:changed_closing_dates, :default => "No"
    	t.integer			:changed_closing_dates_occurance, :default => 0
    	t.string			:followed_closing_instructions, :default => "Yes"
    	t.integer			:followed_closing_instructions_occurance, :default => 0
    	t.string			:changed_nortc_correctly, :default => "NA"
    	t.integer			:changed_nortc_correctly_occurance, :default => 0
    	t.string			:notification_pending_litigation, :default => "No"
    	t.integer			:notification_pending_litigation_occurance, :default => 0
    	t.string			:pay_off_liens, :default => "Yes"
    	t.integer			:pay_off_liens_occurance, :default => 0
    	t.text				:comments
    	t.string			:audited_by
        t.integer           :hud_review
      t.timestamps
    end
  end

  def down
  	drop_table :settlement_agent_audits
  end
end
