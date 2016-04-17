class MenuGroupController < RestrictedAccessController
    


  def index
    @menu = params[:id]
  end
end
