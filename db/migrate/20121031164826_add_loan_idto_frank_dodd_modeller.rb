class AddLoanIdtoFrankDoddModeller < ActiveRecord::Migration
  def up
    change_table :frank_dodd_modellers do |t|
      t.references :loan
    end
  end

  def down
  end
end