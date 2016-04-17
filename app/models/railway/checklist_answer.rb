class ChecklistAnswer < DatabaseRailway
  belongs_to :checklist, foreign_key: 'checklist_id'
  
end
