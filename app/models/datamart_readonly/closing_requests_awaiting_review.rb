class ClosingRequestsAwaitingReview < DatabaseDatamartReadonly
  belongs_to :loan
  has_many :closing_request_notes, -> { where(note_type: 'CLREQ' )}, 
    class_name: 'LoanNote', :foreign_key => 'loan_id', :primary_key => 'id'

  delegate :originator_name, :branch_name, to: :loan, allow_nil: true

  default_scope { order('closing_at asc') }

    # it was faster to get them all then parse them in ruby then to run the query
  def self.counts_by_channel_submitted
    submitted_count = {}
    entries = ClosingRequestsAwaitingReview.select('submitted_at, channel').order('submitted_at ASC')
    entries.each do |row|
      this_submitted = row.submitted_at.strftime('%m/%d/%Y') unless row.submitted_at.blank?
      if this_submitted
        submitted_count[this_submitted] = {Channel.retail.abbreviation => 0, Channel.wholesale.abbreviation => 0} if submitted_count[this_submitted].blank?
        if row.channel.upcase == Channel.retail.abbreviation
          submitted_count[this_submitted][Channel.retail.abbreviation] += 1
        elsif row.channel.upcase == Channel.wholesale.abbreviation
          submitted_count[this_submitted][Channel.wholesale.abbreviation] += 1
        end
      end

    end
    submitted_count
  end

  # it was faster to get them all then parse them in ruby then to run the query
  def self.counts_by_channel_closed
    closed_count = {}
    entries = ClosingRequestsAwaitingReview.select('closing_at, channel').order('closing_at ASC')
    entries.each do |row|
      this_closing = row.closing_at.strftime('%m/%d/%Y') unless row.closing_at.blank?
      if this_closing
        closed_count[this_closing] = {Channel.retail.abbreviation => 0, Channel.wholesale.abbreviation => 0} if closed_count[this_closing].blank?
        if row.channel.upcase == Channel.retail.abbreviation
          closed_count[this_closing][Channel.retail.abbreviation] += 1
        elsif row.channel.upcase == Channel.wholesale.abbreviation
          closed_count[this_closing][Channel.wholesale.abbreviation] += 1
        end
      end
    end
    closed_count
  end

  CREATE_VIEW_SQL = <<-eos
      SELECT     TOP (100) PERCENT
                 v.LoanNum_numeric                                                   AS id,
                 v.LoanNum_numeric                                                   AS loan_id,
                 SUBSTRING(lp._Type,1,4)                                             AS loan_purpose,
                 v.PipelineLoanStatusDescription                                     AS loan_status,
                 v.Borr1LastName                                                     AS borrower,
                 p.[_State]                                                          AS state,
                 lf.LoanScheduledClosingDate                                         AS closing_at,
                 le.EventDate                                                        AS submitted_at,
                 ld.LockExpirationDate                                               AS lock_expire_at,
                 SUBSTRING(v.Channel, 1, 2)                                          AS channel,
                 (SELECT LEFT(u.FirstName,1) + ' ' + u.LastName FROM LENDER_LOAN_SERVICE.[dbo].[USER] AS u WHERE u.User_Id = i.AEUserId) AS area_manager
      FROM LENDER_LOAN_SERVICE.dbo.vwLoan   AS v
        INNER JOIN LENDER_LOAN_SERVICE.dbo.PROPERTY AS p
          ON  v.PipelineLoanStatusDescription
            IN ('Closing Request Received', 'U/W Approved w/Conditions', 'U/W Final Approval/Ready for Docs', 'U/W Final Approval/Ready to Fund')
          AND p.loanGeneral_Id = v.loanGeneral_Id
        INNER JOIN LENDER_LOAN_SERVICE.dbo.LOAN_FEATURES AS lf
          ON  lf.loanGeneral_Id = v.loanGeneral_Id
          AND ISNULL(lf.LoanScheduledClosingDate,getdate() + 1) >= getdate()
        INNER JOIN LENDER_LOAN_SERVICE.dbo.LOAN_PURPOSE AS lp
          ON lp.loanGeneral_Id = v.loanGeneral_Id
        INNER JOIN LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS AS ld
          ON ld.loanGeneral_Id = v.loanGeneral_Id
        INNER JOIN LENDER_LOAN_SERVICE.dbo.INSTITUTION AS i
          ON i.InstitutionNumber = v.InstitutionIdentifier
        INNER JOIN LENDER_LOAN_SERVICE.dbo.LOAN_EVENT AS le
          ON  le.loanGeneral_Id = v.loanGeneral_Id
          AND le.LOAN_EVENT_id =
            (SELECT MAX(le2.LOAN_EVENT_id) FROM LENDER_LOAN_SERVICE.dbo.LOAN_EVENT AS le2
              WHERE le2.loanGeneral_Id = v.loanGeneral_Id
              AND le2.EventDate =
                (SELECT MAX(le3.EventDate) FROM LENDER_LOAN_SERVICE.dbo.LOAN_EVENT AS le3
                  WHERE le3.loanGeneral_Id = v.loanGeneral_Id
                  AND le3.EventDescription IN ('Closing Request Submitted', 'Add Loan Status - Closing Request Received', 'Update Loan Status - Closing Request Received')
                 )
            )
          AND NOT EXISTS
            (SELECT 1 FROM LENDER_LOAN_SERVICE.dbo.LOAN_EVENT AS le4
              WHERE le4.loanGeneral_Id = v.loanGeneral_Id
              AND le4.EventDescription IN ('Closing Request Released', 'Add Loan Status - Closing Cancelled/Postponed', 'Update Loan Status - Closing Cancelled/Postponed')
              AND le4.EventDate > le.EventDate
            )
          AND NOT EXISTS
            (SELECT 1 FROM LENDER_LOAN_SERVICE.dbo.Loan_ASSIGNEE AS la2
              WHERE la2.loanGeneral_Id = v.loanGeneral_Id
              AND la2._role IN ('Closer','Closer/Funder')
              AND la2.AssignedDate IS NOT NULL
            )
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def latest_note_text
    closing_request_notes.first.text
  end
  def note_last_updated_by
    closing_request_notes.first.try(:last_updated_by)
  end
end

