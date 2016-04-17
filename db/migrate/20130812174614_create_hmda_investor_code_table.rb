class CreateHmdaInvestorCodeTable < ActiveRecord::Migration
  def change
    create_table :hmda_investor_codes do |t|
      t.string :investor_code
      t.string :investor_name

      t.timestamps
    end
  end
end
