class Core::InstitutionsController < ApplicationController
  
  def index
    @institutions = Institution.all_retail.order("is_active desc, city asc, institution_number asc").page(params[:page]).per(20)
  end

  def show
    @institution = Institution.where(id: params[:id]).last
  end

end