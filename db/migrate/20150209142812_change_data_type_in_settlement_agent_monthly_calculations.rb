class ChangeDataTypeInSettlementAgentMonthlyCalculations < ActiveRecord::Migration
  def up
    change_column :settlement_agent_monthly_calculations, :settlement_agent_id, :string
  end

  def down
    change_column :settlement_agent_monthly_calculations, :settlement_agent_id, :integer
  end
end
