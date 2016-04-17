class DenialLetter < DatabaseDatamartReadonly

  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT
        DENIAL_LETTER_id as id,
        loanGeneral_Id as loan_general_id,
        _MailedDate as mailed_at,
        _DeniedDate as denied_at,
        _CancelWithdrawnDate as cancel_withdrawn_at,
        ExcludedFromHMDADate as excluded_from_hmda_at,
        PreApprovalDeniedDate as pre_approval_denied_at,
        PreApprovalNotAcceptedDate as pre_approval_not_accepted_at,
        DeniedbyName as denied_by_name

      FROM       LENDER_LOAN_SERVICE.dbo.[DENIAL_LETTER]
    eos
  end
end
