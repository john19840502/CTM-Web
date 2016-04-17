class CreateDmiXrefs < ActiveRecord::Migration
  def change
    create_table :dmi_xrefs do |t|
      t.integer :dmi_xref_import_id
      t.string :min_num
      t.string :dmi_num

      t.timestamps
    end
    add_index :dmi_xrefs, :min_num
  end
end
