class AddCityStateToEscrowAgent < ActiveRecord::Migration
  def change
  	add_column :escrow_agents, :city, :string
  	add_column :escrow_agents, :state, :string
  end
end
