class UwSubmittedNotReceived < DatabaseDatamartReadonly
  belongs_to :ctm_loan, foreign_key: :loan_id, primary_key: :loan_id
  belongs_to :loan_general, foreign_key: :id
  delegate :coordinator, :coordinator_id=, :coordinator_id, to: :ctm_loan, allow_nil: true
  delegate :property_state, to: :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT     TOP (100) PERCENT v.loanGeneral_Id AS id, v.LoanNum AS loan_id, CONVERT(VARCHAR, cl.UW_Submit_Date, 111) AS uw_submitted_at, DATEDIFF(d,
                            cl.UW_Submit_Date, GETDATE()) AS age, cl.UW_Coord_Submission AS coordinator_pid, v.Channel AS channel, SUBSTRING(lp._Type, 1, 4) AS purpose,
                            v.Borr1LastName AS borrower_last_name, mt.MortgageType AS mortgage_type, ud.ProductCode AS product_code,
                                (SELECT     AttributeValue
                                  FROM          LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD AS cf2
                                  WHERE      (loanGeneral_Id = v.loanGeneral_Id) AND (FormUniqueName = cf.FormUniqueName) AND (InstanceSequence = cf.InstanceSequence) AND
                                                         (AttributeUniqueName = 'UWSubmissionMIType')) AS is_mi_required, CAST(CASE WHEN v.LoanAmount > 417000 THEN - 1 ELSE 0 END AS bit)
                            AS is_jumbo_candidate, CASE WHEN cl.UW_Coord_Submission IS NULL THEN NULL ELSE
                                (SELECT     cu2.Domain_Login
                                  FROM          CTM.ctm.CTM_User cu2
                                  WHERE      cu2.PID = cl.UW_Coord_Submission) END AS login,
                            (SELECT cf2.AttributeValue FROM LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD cf2 WHERE cf2.loanGeneral_Id = v.loanGeneral_Id AND cf2.FormUniqueName = cf.FormUniqueName AND cf2.InstanceSequence = cf.InstanceSequence AND cf2.AttributeUniqueName = 'UWSubmissionPreApproval') AS pre_approval,
                            v.InstitutionIdentifier AS institution_id,
                            CASE WHEN cv.CodeValue IS NULL THEN 'No' ELSE 'Yes' END AS is_amera_branch
      FROM         LENDER_LOAN_SERVICE.dbo.vwLoan AS v INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.LOAN_PURPOSE AS lp ON lp.loanGeneral_Id = v.loanGeneral_Id INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.MORTGAGE_TERMS AS mt ON mt.loanGeneral_Id = v.loanGeneral_Id INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA AS ud ON ud.loanGeneral_Id = v.loanGeneral_Id INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.ctm_Loan AS cl ON cl.Loan_Num = v.LoanNum INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD AS cf ON cf.loanGeneral_Id = v.loanGeneral_Id AND cf.FormUniqueName = 'Submit File to UW' AND
                            cf.InstanceSequence = 1 AND cf.AttributeUniqueName = 'UWSubmission' AND cf.AttributeValue = 'Y' AND NOT EXISTS
                                (SELECT     1 AS Expr1
                                  FROM          LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD AS cf2
                                  WHERE      (loanGeneral_Id = v.loanGeneral_Id) AND (FormUniqueName = cf.FormUniqueName) AND (InstanceSequence = cf.InstanceSequence) AND
                                                         (AttributeUniqueName = 'UWSubmissionRcvd') AND (AttributeValue IS NOT NULL))
                            LEFT JOIN CTM.ctm.CodeValue AS cv ON cv.CodeValue = v.InstitutionIdentifier
                            LEFT JOIN CTM.ctm.CodeSet AS cs ON cs.SetName = 'Amera Branches' AND cs.ID = cv.CodeSetID
      ORDER BY uw_submitted_at
    eos

  # specific filters
  scope :amera_only, where(:is_amera_branch => 'Yes')
  scope :ctm_only, where(:is_amera_branch => 'No')

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def self.missing_uw_submission_date_count
    self.where(:uw_submitted_at => nil).count
  end

  def self.date_counts
    #groups = self.select(:uw_submitted_at).order(:uw_submitted_at).all.chunk{|n| n.uw_submitted_at}
    #groups.map{ |date, records_with_that_date| [date, records_with_that_date.size] }
    self.group(:uw_submitted_at).count
  end

  # it was faster to get them all then parse them in ruby then to run the query
  def self.counts_by_channel
    count_list = {}
    entries = self.select('uw_submitted_at, channel').order('uw_submitted_at ASC')
    entries.each do |row|
      this_date = Date.parse(row.uw_submitted_at).strftime('%m/%d/%Y')
      count_list[this_date] = {Channel.retail.abbreviation => 0, Channel.wholesale.abbreviation => 0, Channel.reimbursement.abbreviation => 0} if count_list[this_date].blank?
      if row.channel[0..1].upcase == Channel.retail.abbreviation
        count_list[this_date][Channel.retail.abbreviation] += 1
      elsif row.channel[0..1].upcase == Channel.wholesale.abbreviation
        count_list[this_date][Channel.wholesale.abbreviation] += 1
      elsif row.channel[0..1].upcase == Channel.reimbursement.abbreviation
        count_list[this_date][Channel.reimbursement.abbreviation] += 1
      end
    end
    count_list
  end

  def branch
    (is_amera_branch == "Yes") ? "Amera (#{institution_id})" : "CTM (#{institution_id})"
  end
end

