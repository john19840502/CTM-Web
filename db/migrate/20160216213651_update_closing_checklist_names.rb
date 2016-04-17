class UpdateClosingChecklistNames < ActiveRecord::Migration
  def up
    execute "update #{ChecklistAnswer.table_name} set name = 'condo_policy_good_for_60_days' where name = 'condo_policy_good_for_90_days'"   
    execute "update #{ChecklistAnswer.table_name} set name = 'condo_60_day_note_codes' where name = 'condo_90_day_note_codes'"   
    execute "update #{ChecklistAnswer.table_name} set name = 'condo_60_day_underwriting_condition' where name = 'condo_90_day_underwriting_condition'"   
  end

  def down
    execute "update #{ChecklistAnswer.table_name} set name = 'condo_policy_good_for_90_days' where name = 'condo_policy_good_for_60_days'"   
    execute "update #{ChecklistAnswer.table_name} set name = 'condo_90_day_note_codes' where name = 'condo_60_day_note_codes'"   
    execute "update #{ChecklistAnswer.table_name} set name = 'condo_90_day_underwriting_condition' where name = 'condo_60_day_underwriting_condition'"   
  end


end
