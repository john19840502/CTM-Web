class GfeAdditionalDatum < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT  [GFE_ADDITIONAL_DATA_id]    AS id,
              [loanGeneral_Id]            AS loan_general_id,
              [DatePrepared]              AS date_prepared,
              [BrokerName]                AS broker_name,
              [BrokerStreetAddress]       AS broker_street_address,
              [BrokerCity]                AS broker_city,
              [BrokerState]               AS broker_state,
              [BrokerPostalCode]          AS broker_postal_code,
              [EstimatedClosingDate]      AS estimated_closing_date,
              [EstimatedFirstPaymentDate] AS estimated_first_payment_date
      FROM       LENDER_LOAN_SERVICE.dbo.[GFE_ADDITIONAL_DATA]
    eos



  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end


# [PurchasOrPayoffAmount] [money] NULL
# [OtherEquityAmount] [money] NULL
