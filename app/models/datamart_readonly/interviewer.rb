# This is the originator listed on the 1003 form for the loan.
class Interviewer < DatabaseDatamartReadonly
  belongs_to :loan

  CREATE_VIEW_SQL =  <<-eos
      SELECT     INTERVIEWER_INFORMATION_id             AS id,
                 i.loanGeneral_id                       AS loan_general_id,
                 loanNum                                AS loan_id,
                 ApplicationTakenMethodType             AS application_taken_method_type, --["Telephone", "FaceToFace", "", "Internet", "Mail"],
                 InterviewerApplicationSignedDate       AS interviewer_application_signed_at,
                 InterviewersEmployerName               AS employer_name,
                 InterviewersName                       AS name,
                 OriginatorCompanyIdentifier            AS institution_nmls_id,
                 OriginatorIdentifier                   AS individual_nmls_id
      FROM       LENDER_LOAN_SERVICE.dbo.[INTERVIEWER_INFORMATION] AS i JOIN LENDER_LOAN_SERVICE.dbo.[vwLoan] as l on i.loanGeneral_id = l.loanGeneral_id
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end

