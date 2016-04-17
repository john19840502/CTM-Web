class DropEffectiveDateFromRegionStates < ActiveRecord::Migration
  def up
    remove_column :region_states, :effective_date
  end

  def down
    add_column :region_states, :effective_date, :datetime
  end
end
