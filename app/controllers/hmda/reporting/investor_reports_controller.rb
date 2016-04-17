class Hmda::Reporting::InvestorReportsController < RestrictedAccessController
    


  
  def index
    @from_date = Date.parse(params[:hmda_report][:from_date]) rescue 10.years.ago
    @to_date   = Date.parse(params[:hmda_report][:to_date]) rescue Time.now
    
    @records = Loan.funded.unsold.funded_between(@from_date, @to_date).order(:funded_at)
    
    # Define the columns we want displayed - we'll meta program the crap out of this one - Hans
    @columns = [ :loan_num, :borrower_last_name, :borrower_first_name, :funded_at ]
    
    respond_to do |format|
      format.html
      format.json
      
      # TODO - Filename does not appear to be honored - Hans
      format.xls {
        send_data @records.to_xls(:name     => "HMDA Investor Report",
                                   :columns  => @columns,
                                   :headers  => @columns.map{|c| c.to_s.humanize},
                                   :filename => "HMDA Investor Report #{I18n.l(@from_date, :format => :yyyy_mm_dd)} to #{I18n.l(@to_date, :format => :yyyy_mm_dd)}.xls")
      } # xls
    end # respond_to
  end
end
