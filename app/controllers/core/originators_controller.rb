class Core::OriginatorsController < ApplicationController

  def index
    # redirect_to search_core_originators_path if params[:emp_name].present?
    
    if params[:parent].present? 
      if params[:parent].eql?("branch")
        
        @header = Institution.where(id: params[:pid]).last
        @added_id = "_#{params[:pid]}"

        qry = BranchEmployee.retail_with_branch(params[:pid])
      elsif params[:parent].eql?("compensation")
        qry = BranchCompensation.where(id: params[:pid]).last.employees
      end
    else
      qry = BranchEmployee.retail                      
    end

    if params[:emp_name].present?
      lname = "%#{params[:emp_name]}%"
      qry = qry.where{ last_name =~ lname }
    end

    @originators = qry.order("is_active desc, last_name asc").page(params[:page]).per(20)
  end

  def search
    if params[:emp_name].present?
      param = "%#{params[:emp_name]}%"
      @originators = BranchEmployee.retail.where{ last_name =~ param }.order("is_active desc, last_name asc").page(params[:page]).per(20)
      render :index
    else
      redirect_to core_originators_path 
    end
  end

  def show
    @originator = BranchEmployee.where(id: params[:id]).last
  end
end
