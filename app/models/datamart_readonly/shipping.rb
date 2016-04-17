class Shipping < DatabaseDatamartReadonly
  belongs_to :loan_general
  belongs_to :closing_request_received, :foreign_key => 'loan_general_id', :primary_key => 'id'

  scope :file_received, where{file_received_at != nil}
  scope :not_shipped, where(:shipped_to_investor_at => nil, :shipped_to_servicer_at => nil)

 CREATE_VIEW_SQL = <<-EOS
    SELECT
      SHIPPING_id AS id,
      loanGeneral_Id AS loan_general_id,
      _FileReceivedDate AS file_received_at
    FROM       LENDER_LOAN_SERVICE.dbo.[SHIPPING]
  EOS

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
