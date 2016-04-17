require 'filter_by_date_model_methods'

class ClosingRequestReceived < DatabaseDatamartReadonly
  extend FilterByDateModelMethods

  def self.sqlserver_create_view
    <<-eos
      SELECT     v.[Loan Nbr]                     AS id,
                 v.[Loan Nbr]                     AS loan_id,
                 v.[Borrower]                     AS borrower,
                 v.[Branch]                       AS branch,
                 v.[Loan Originator]              AS loan_originator,
                 v.[Area Manager]                 AS area_manager,
                 v.[Assigned To]                  AS assigned_to,
                 v.[Loan Purpose]                 AS loan_purpose,
                 v.[Loan Status]                  AS loan_status,
                 v.[Property State]               AS property_state,
                 v.[Closing Request Received]     AS closing_request_received_at,
                 v.[Docs Out]                     AS docs_out_at,
                 v.[Total Hours]                  AS total_hours,
                 v.[Funding Request Received]     AS funding_request_received_at,
                 v.[Closed]                       AS closed_at,
                 v.[Funded]                       AS funded_at,
                 v.[Closing Cancelled/Postponed]  AS closing_cancelled_postponed_at,
                 v.[Shipping Received]            AS shipping_received_at,
                 v.[Role]                         AS role

      FROM LENDER_LOAN_SERVICE.dbo.vwClosingRequestsReceived AS v
    eos
  end

  def self.filter_by_date_method
    :closing_request_received_at
  end
end
