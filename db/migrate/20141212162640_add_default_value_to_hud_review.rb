class AddDefaultValueToHudReview < ActiveRecord::Migration
  def up
  	change_column :settlement_agent_audits, :hud_review, :integer, :default => 0
  end

  def down
  	change_column :settlement_agent_audits, :hud_review, :integer, :default => nil
  end
end
