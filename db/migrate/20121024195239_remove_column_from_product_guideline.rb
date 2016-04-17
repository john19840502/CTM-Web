class RemoveColumnFromProductGuideline < ActiveRecord::Migration
  def up
    remove_column :product_guidelines, :effective_date
  end

  def down
    add_column :product_guidelines, :effective_date, :date
  end
end
