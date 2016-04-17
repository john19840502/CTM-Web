class InvestorPricingImportsController < ApplicationController  
  def index
    data.model = model

    respond_to do |format|
      format.html
      format.json { render json: data.as_json(params) }
    end
  end

  def new
    @investor_pricing = model.new
  end

  def create
    model.parse_file(params[:investor_pricing_import][:file])
    redirect_to investor_pricing_imports_url
  end

  def model
    InvestorPricingImport
  end

  def list_authorized?
    can? :manage, InvestorPricingImport
  end

  def create_authorized?
    can? :manage, InvestorPricingImport
  end

  def delete_authorized?
    can? :manage, InvestorPricingImport
  end
end