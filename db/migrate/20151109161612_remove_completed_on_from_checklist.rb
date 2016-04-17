class RemoveCompletedOnFromChecklist < ActiveRecord::Migration
  def self.up
    remove_column :checklists, :complteted_on
  end
  def self.down
    add_column :checklists, :complteted_on, :datetime
  end
end
