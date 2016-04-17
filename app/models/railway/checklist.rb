class Checklist < DatabaseRailway
  belongs_to :loan, foreign_key: 'loan_num'
  has_many :checklist_answers, foreign_key: 'checklist_id'
end