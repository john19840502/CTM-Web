class UwManagement::FilesToBeUnderwrittenController < RestrictedAccessController
  helper 'uw_coordinator/file_submitted_not_received'

  def index
    data.label = 'Underwriting Pipeline'
    data.model = FilesToBeUnderwritten
    data.columns = [:purpose, :channel, :submitted_at, :age, :received_at, :loan_num, :borrower, :mortgage_type, :product_code, :underwriter_name, :status]
    data.records = FilesToBeUnderwritten.order('purpose ASC, age DESC')
    respond_to do |format|
      format.html
      format.xls { send_data data.to_xls }
    end
  end

end
