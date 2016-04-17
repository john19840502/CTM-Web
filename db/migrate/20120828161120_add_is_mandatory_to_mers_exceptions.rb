class AddIsMandatoryToMersExceptions < ActiveRecord::Migration
  def change
    add_column :mers_exceptions, :is_mandatory, :boolean
    add_column :mers_exceptions, :fuzzy_score, :decimal, :precision => 10, :scale => 9, :default => 0.00
    add_index :mers_exceptions, :is_mandatory
    add_index :mers_exceptions, :fuzzy_score
  end
end
