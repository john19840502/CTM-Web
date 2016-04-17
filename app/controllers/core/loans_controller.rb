class Core::LoansController < RestrictedAccessController
    
  def index
    @added_id = ''
    loans = Master::Loan.all_retail
    if params[:parent].present? 
      if params[:parent].eql?("lo")
        @header = BranchEmployee.where(username: params[:pid]).last
        if params[:bid].present?
          loans = @header.loans_for_branch(params[:bid])
        else
          loans = @header.loans
        end          

        @added_id = "_#{params[:bid]}" if params[:bid].present?

      elsif params[:parent].eql?("branch")
        @header = Institution.where(institution_number: params[:pid]).last
        loans = @header.loans

        @added_id = "_#{@header.id}"
      end     
    end

    loans = setup_search_query(loans)

    @loans = loans.order('funded_at desc, loan_num').page(params[:page]).per(20)

  end

  def search
    loans = Master::Loan.all_retail
    loans = setup_search_query(loans)

    @loans = loans.order('funded_at desc, loan_num').page(params[:page]).per(20)

    render :index
  end

  def show
    @loan = Loan.where(id: params[:id]).last
  end

private  

  def setup_search_query loans
    if params[:loan_num].present?
      param = "#{params[:loan_num]}%"
      loans = loans.where{ (loan_num =~ param) }
    end

    if params[:branch_name].present?
      param = "%#{params[:branch_name]}%"
      loans = loans.joins(:branch).where{ (branch.city =~ param) }
    end

    if params[:emp_name].present?
      param = "%#{params[:emp_name]}%"
      loans = loans.where{ broker_last_name =~ param }
    end    

    loans
  end
end
