class CreateBrokerCompModelerTable < ActiveRecord::Migration
  def change
    create_table :broker_comp_modelers do |t|
      t.string :broker_first_name
      t.string :broker_last_name
      t.string :comp_tier
      t.string :loan_amt
      t.string :max_broker_comp
      t.string :total_broker_comp_gfe
      t.text   :user_comments
      t.string :modeler_date_time
      t.string :modeler_user

      t.timestamps
    end
  end
end
