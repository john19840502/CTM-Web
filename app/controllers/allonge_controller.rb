class AllongeController < ApplicationController

  def allonges
    @loans = Master::Loan.where(loan_num: [ 1022358, 1053697, 1030773, 1032348, 1058318, 1048180, 1053341, 1052653, 1078913, 1012046, ])
    @successors = {
      '1022358' => "flasjfsalfkj",
      '1052653' => "boobllblaksjf",
    }

    @debug = params[:debug]

    respond_to do |format|
      format.html
      format.pdf do
        render pdf_options(params[:debug])
      end
    end
  end

  def string_report(loans, successors)
    @loans = loans
    @successors = successors
    render_to_string pdf_options.merge({
      :template => 'allonge/allonges.pdf'
    })
  end

  private

  def pdf_options(debug = false)
    { :pdf => "foo", 
      :show_as_html => debug,
      :layout => 'allonges', 
      :margin => { :top => 30 },
      :dpi => 600
    }
  end



end
