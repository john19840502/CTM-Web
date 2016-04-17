class LoanPurpose < DatabaseDatamartReadonly
  belongs_to :closing_request_received, :foreign_key => 'loan_general_id', :primary_key => 'id'
  belongs_to :loan_general

  alias_attribute :to_s, :loan_type

  CREATE_VIEW_SQL = <<-eos
      SELECT LOAN_PURPOSE_id                    AS id,
             loanGeneral_Id                     AS loan_general_id,
             GSETitleMannerHeldDescription      AS gse_title_manner_held_description,
             [_Type]                            AS loan_type,
             OtherLoanPurposeDescription        AS other_loan_purpose_description,
             PropertyLeaseholdExpirationDate    AS property_leasehold_expired_at,
             PropertyRightsType                 AS property_rights_type,
             PropertyUsageType                  AS property_usage_type
      FROM       LENDER_LOAN_SERVICE.dbo.[LOAN_PURPOSE]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def is_purchase?
    loan_type.downcase == 'purchase'
  end

  def is_refi?
    loan_type.downcase == 'refinance'
  end
end
