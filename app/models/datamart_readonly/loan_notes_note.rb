class LoanNotesNote < DatabaseDatamartReadonly
  belongs_to :loan_general
  
  def self.sqlserver_create_view
    <<-eos
      SELECT     LOAN_NOTES_NOTE_id                AS id,
             loanGeneral_Id                     AS loan_general_id,
             _CreatedDate                       AS created_date,
             _NoteFor                           AS note_for,
             _Content                           AS content
      FROM       LENDER_LOAN_SERVICE.dbo.[LOAN_NOTES_NOTE]
    eos
  end

  # [ and ] are used for pattern matching.  LIKE'[[]' matches '[', LIKE']' matches ']'
  scope :voe_completed_dates, ->{ where("lower(content) like '%[[]vc]%'") }

end
