class CreateUsageStats < ActiveRecord::Migration
  def change
    create_table :usage_stats do |t|
      t.string :username
      t.string :controller_name
      t.string :action_name
      t.string :request_hash, limit: 2000
      t.string :session_hash, limit: 2000
      t.string :ip_address
      t.string :referrer
      t.text :message

      t.timestamps
    end
    add_index :usage_stats, :username
    add_index :usage_stats, [:controller_name, :action_name]
    add_index :usage_stats, :ip_address
    add_index :usage_stats, :referrer
  end
end
