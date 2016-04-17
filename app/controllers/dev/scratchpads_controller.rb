class Dev::ScratchpadsController < RestrictedAccessController
    



  def index
    @from_date = Date.parse(params[:hmda_report][:from_date]) rescue 1.year.ago
    @to_date   = Date.parse(params[:hmda_report][:to_date]) rescue Time.now
    @loans = Loan.funded.funded_between(@from_date, @to_date).unsold.order(:funded_at)
  end
end
