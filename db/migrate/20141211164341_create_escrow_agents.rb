class CreateEscrowAgents < ActiveRecord::Migration
  def change
    create_table :escrow_agents do |t|
      t.string :name
      t.string :address
      t.string :zip_code

      t.timestamps
    end
  end
end
