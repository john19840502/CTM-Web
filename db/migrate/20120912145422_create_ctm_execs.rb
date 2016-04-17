class CreateCtmExecs < ActiveRecord::Migration
  def change
    create_table :ctm_execs do |t|
      t.string :first_name
      t.string :middle_initial
      t.string :last_name
      t.string :uuid

      t.timestamps
    end

    add_index :ctm_execs, :first_name
    add_index :ctm_execs, :last_name
    add_index :ctm_execs, :middle_initial
    add_index :ctm_execs, :uuid
  end
end
