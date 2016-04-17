class AddPositionToCtExecs < ActiveRecord::Migration
  def change
    add_column :ctm_execs, :position, :string
  end
end
