class ServiceOrder < DatabaseDatamartReadonly
  belongs_to :loan, foreign_key: :loan_id, primary_key: :loan_num

  CREATE_VIEW_SQL = <<-eos
      SELECT
        OrderID                     AS id,
        LoanID                      AS loan_id,
        SentDate                    AS sent_date,
        SentMethod                  AS sent_method
      FROM       CTM.pac.[ServiceOrders]
    eos
  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end