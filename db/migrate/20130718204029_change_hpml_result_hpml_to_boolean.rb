class ChangeHpmlResultHpmlToBoolean < ActiveRecord::Migration
  def up
    change_column :hpml_results, :hpml, :boolean
  end

  def down
    change_column :hpml_results, :hpml, :string
  end
end
