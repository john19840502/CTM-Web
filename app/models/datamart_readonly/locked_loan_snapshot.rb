class LockedLoanSnapshot < DatabaseDatamartReadonly
  belongs_to :loan

  def self.sqlserver_create_view
    <<-eos
      SELECT     lg.LenderRegistrationIdentifier AS id, lg.LenderRegistrationIdentifier AS loan_id, lld.EscrowWaiverIndicator AS is_escrow_waived
      FROM         LENDER_LOAN_SERVICE.dbo.LOAN_GENERAL AS lg INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.LOCK_LOAN_DATA AS lld ON lg.loanGeneral_Id = lld.loanGeneral_Id
    eos
  end
end
