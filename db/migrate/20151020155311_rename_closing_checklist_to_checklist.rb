class RenameClosingChecklistToChecklist < ActiveRecord::Migration
  def self.up
    rename_table :closing_checklists, :checklists
  end

  def self.down
    rename_table :checklists, :closing_checklists
  end
end
