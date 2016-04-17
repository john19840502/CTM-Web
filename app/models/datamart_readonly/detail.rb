class Detail < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT
        [_DETAILS_id] AS id,
        [loanGeneral_Id] AS loan_general_id,
        [ProjectName] AS project_name

      FROM         LENDER_LOAN_SERVICE.dbo._DETAILS
    eos
  end
end
