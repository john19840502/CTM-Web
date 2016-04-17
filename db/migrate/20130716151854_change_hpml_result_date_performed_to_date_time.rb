class ChangeHpmlResultDatePerformedToDateTime < ActiveRecord::Migration
  def up
    change_column :hpml_results, :date_performed, :datetime
  end

  def down
    change_column :hpml_results, :date_performed, :string
  end
end
