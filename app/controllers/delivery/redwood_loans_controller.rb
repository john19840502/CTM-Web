module Delivery
  class RedwoodLoansController < RestrictedAccessController

    def index
      data.model = RedwoodLoan
      data.columns = data.model.column_names

      respond_to do |format|
        format.html
        format.xls { send_data data.to_xls }
      end
    end

    def export
      @loans = RedwoodLoan.all

      headers['Content-Type'] = "application/xml"
      headers['Content-Disposition'] = 'attachment; filename="redwood_loans.xml"'
      headers['Cache-Control'] = ''
    end
  end
end