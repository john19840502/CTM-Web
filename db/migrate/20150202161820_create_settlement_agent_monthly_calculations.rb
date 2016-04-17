class CreateSettlementAgentMonthlyCalculations < ActiveRecord::Migration
  def change
    create_table :settlement_agent_monthly_calculations do |t|
    	t.datetime :month
    	t.integer :settlement_agent_id
    	t.integer :escrow_agent_id
    	t.integer :hud_review, :default => 0
    	t.integer :other_error_count, :default => 0
    	t.integer :loans_funded, :default => 0
      t.timestamps
    end
  end
end
