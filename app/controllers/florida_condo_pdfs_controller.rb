class FloridaCondoPdfsController < RestrictedAccessController
  def index
    @perse_list = FloridaCondoPdf.order('created_at DESC').page(params[:page]).per(12) 
  end
end