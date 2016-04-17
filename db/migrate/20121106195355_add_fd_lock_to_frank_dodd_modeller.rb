class AddFdLockToFrankDoddModeller < ActiveRecord::Migration
  def change
    add_column :frank_dodd_modellers, :fd_lock, :boolean
  end
end
