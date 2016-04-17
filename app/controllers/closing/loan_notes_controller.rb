class Closing::LoanNotesController < RestrictedAccessController
    




  def index
    data.label = 'Loan Notes'
    data.model = LoanNote
    data.columns = [:id, :loan_id, :text, :last_updated_by]
  end

end
