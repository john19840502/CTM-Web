class ClosingRequestReadyForDoc < DatabaseDatamartReadonly
  belongs_to :loan
  belongs_to :loan_general

  scope :by_closing_date_asc, -> { order('closed_at ASC') }

  # {"01/25/12"=>3, "01/26/12"=>16, "01/27/12"=>21}
  def self.count_by_date
    self.group(:closing_date).count
  end

  # it was faster to get them all then parse them in ruby then to run the query
  def self.counts_by_channel
    count_list = {}
    entries = ClosingRequestReadyForDoc.select('closed_at, channel').order('closed_at ASC')
    entries.each do |row|
      this_date = row.closed_at.strftime('%m/%d/%Y')
      count_list[this_date] = {Channel.retail.abbreviation => 0, Channel.wholesale.abbreviation => 0, Channel.reimbursement.abbreviation => 0} if count_list[this_date].blank?
      if row.channel.upcase == Channel.retail.abbreviation
        count_list[this_date][Channel.retail.abbreviation] += 1
      elsif row.channel.upcase == Channel.wholesale.abbreviation
        count_list[this_date][Channel.wholesale.abbreviation] += 1
      elsif row.channel.upcase == Channel.reimbursement.abbreviation
        count_list[this_date][Channel.reimbursement.abbreviation] += 1
      end
    end
    count_list
  end

  CREATE_VIEW_SQL =  <<-eos
      SELECT le.LOAN_EVENT_id AS id,
           v.loanGeneral_Id AS loan_general_id,
             v.LoanNum AS loan_id,
             SUBSTRING(lp.[_Type],1,4) AS purpose,
             v.PipelineLoanStatusDescription AS status,
             v.Borr1LastName AS borrower_last_name,
             p.[_State] AS state,
             lf.LoanScheduledClosingDate AS closed_at,
             le.[EventDate] AS requester_submitted_at,
             u.[UserName] AS assigned_to,
             v.BranchName AS branch_name,
             SUBSTRING(v.Channel, 1, 2) as channel,
             CONVERT(VARCHAR, lf.LoanScheduledClosingDate, 1) AS closing_date
        FROM LENDER_LOAN_SERVICE.[dbo].[vwLoan] AS v
             INNER JOIN LENDER_LOAN_SERVICE.[dbo].[PROPERTY] AS p
               ON (v.PipeLineLoanStatusDescription IN
                  ('Closing Cancelled/Postponed',
                   'Closing Request Received',
                   'Funded','Funding Request Received',
                   'U/W Approved w/Conditions',
                   'U/W Conditions Pending Review',
                   'U/W Final Approval/Ready for Docs',
                   'U/W Final Approval/Ready to Fund',
                   'Closed')
               AND p.loanGeneral_Id = v.loanGeneral_Id)
             INNER JOIN LENDER_LOAN_SERVICE.[dbo].[Loan_ASSIGNEE] AS la
               ON (la.loanGeneral_Id = v.loanGeneral_Id
               AND la._role IN ('Closer','Closer/Funder')
               AND la.AssignedDate IS NOT NULL)
             INNER JOIN LENDER_LOAN_SERVICE.[dbo].[USER] u
               ON u.USER_Id = la._AssignedUserId
             INNER JOIN LENDER_LOAN_SERVICE.[dbo].[LOAN_PURPOSE] AS lp
               ON lp.loanGeneral_Id = v.loanGeneral_Id
             INNER JOIN LENDER_LOAN_SERVICE.[dbo].[LOAN_FEATURES] AS lf
               ON lf.loanGeneral_Id = v.loanGeneral_Id
             INNER JOIN [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] as le
               ON (le.loanGeneral_Id = v.loanGeneral_Id
               AND le.LOAN_EVENT_id =
                  (SELECT MAX(le2.LOAN_EVENT_id)
                     FROM LENDER_LOAN_SERVICE.[dbo].[LOAN_EVENT] AS le2
                    WHERE le2.loanGeneral_Id = v.loanGeneral_Id
                      AND le2.EventDate =
                         (SELECT MAX(le3.EventDate)
                            FROM LENDER_LOAN_SERVICE.[dbo].[LOAN_EVENT] AS le3
                           WHERE le3.loanGeneral_Id = v.loanGeneral_Id
                             AND le3.EventDescription IN
                                ('Closing Request Submitted',
                                 'Add Loan Status - Closing Request Received',
                                 'Update Loan Status - Closing Request Received')))
               AND NOT EXISTS
                  (SELECT 1
                     FROM LENDER_LOAN_SERVICE.[dbo].[LOAN_EVENT] AS le4
                    WHERE le4.loanGeneral_Id = v.loanGeneral_Id
                      AND le4.EventDescription IN
                         ('Closing Request Released',
                          'Add Loan Status - Closing Cancelled/Postponed',
                          'Update Loan Status - Closing Cancelled/Postponed')
                      AND le4.EventDate > le.EventDate)
               AND NOT EXISTS
                  (SELECT 1
                     FROM LENDER_LOAN_SERVICE.[dbo].[LOAN_EVENT] AS le5
                    WHERE le5.loanGeneral_Id = v.loanGeneral_Id
                      AND le5.EventDescription IN
                         ('Add Loan Status - Docs Out',
                          'Update Loan Status - Docs Out')
                      AND le5.EventDate > le.EventDate
                      AND NOT EXISTS
                         (SELECT 1
                            FROM LENDER_LOAN_SERVICE.[dbo].[LOAN_EVENT] AS le6
                           WHERE le6.loanGeneral_Id = le5.loanGeneral_Id
                             AND le6.EventDescription IN
                                ('Closing Request Released',
                                 'Add Loan Status - Closing Cancelled/Postponed',
                                 'Update Loan Status - Closing Cancelled/Postponed')
                             AND le6.EventDate > le5.EventDate)))
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  # Alias
  def requester_submitted_date
    requester_submitted_at
  end

  def closing_date
    closed_at
  end
end
