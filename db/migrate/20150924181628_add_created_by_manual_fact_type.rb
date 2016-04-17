class AddCreatedByManualFactType < ActiveRecord::Migration
  def change
    add_column :manual_fact_types, :created_by, :string
  end
end
