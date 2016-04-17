class AddNewColumnsClosingChecklist < ActiveRecord::Migration
  def up
    add_column :closing_checklists, :type, :string
    add_column :closing_checklists, :version, :integer
    add_column :closing_checklists, :created_by, :string
    add_column :closing_checklists, :completed_by, :string
    add_column :closing_checklists, :complteted_on, :datetime
    add_column :closing_checklists, :completed, :boolean, default: false
  end

  def down
    remove_column :closing_checklists, :type
    remove_column :closing_checklists, :version
    remove_column :closing_checklists, :created_by
    remove_column :closing_checklists, :completed_by
    remove_column :closing_checklists, :completed_on
    remove_column :closing_checklists, :completed
  end
end
