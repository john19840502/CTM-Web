class AddTempOrgTouser < ActiveRecord::Migration
  def change
    add_column :users, :temp_org, :string
  end
end
