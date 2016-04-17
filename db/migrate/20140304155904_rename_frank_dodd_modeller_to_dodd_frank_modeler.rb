class RenameFrankDoddModellerToDoddFrankModeler < ActiveRecord::Migration
  def self.up
    rename_table :frank_dodd_modellers, :dodd_frank_modelers
  end 
  def self.down
    rename_table :dodd_frank_modelers, :frank_dodd_modellers
  end
end
