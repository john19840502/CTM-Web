class AddInvestorCommitmentNumberToSmdsPool < ActiveRecord::Migration
  def change
    add_column :smds_pools, :investor_commitment_number, :string
  end
end
