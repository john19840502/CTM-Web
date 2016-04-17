class UpdateChecklistQuestionNames < ActiveRecord::Migration
  def up
    execute "update #{ChecklistAnswer.table_name} set name = 'hoi_policy_good' where name = 'hoi_policy_good_for_90_days'" 
    execute "update #{ChecklistAnswer.table_name} set name = 'flood_policy_good' where name = 'flood_policy_good_for_90_days'" 
  end

  def down
    execute "update #{ChecklistAnswer.table_name} set name = 'hoi_policy_good_for_90_days' where name = 'hoi_policy_good'" 
    execute "update #{ChecklistAnswer.table_name} set name = 'flood_policy_good_for_90_days' where name = 'flood_policy_good'"
  end
end
