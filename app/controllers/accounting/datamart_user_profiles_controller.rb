class Accounting::DatamartUserProfilesController < RestrictedAccessController
  load_and_authorize_resource class: DatamartUserProfile

  # def index
  #   if params[:pid]
  #     @datamart_user_profile = BranchCompensation.where(id: params[:pid]).last
  #     @employees = @datamart_user_profile.branch.employees - @datamart_user_profile.employees
  #   end
  # end

  def new
    new_params = { datamart_user_id: params[:uid], institution_id: params[:bid] }
    @datamart_user_profile = DatamartUserProfile.new(new_params, without_protection: true)
    profiles = DatamartUserProfile.where(datamart_user_id: @datamart_user_profile.datamart_user_id).pluck(:ultipro_emp_id).uniq
    @datamart_user_profile.ultipro_emp_id = profiles[0] unless profiles.empty?
  end

  def create
    @datamart_user_profile = DatamartUserProfile.new(datamart_user_profile_params, without_protection: true)
    DatamartUserProfile.where(datamart_user_id: @datamart_user_profile.datamart_user_id).update_all(ultipro_emp_id: @datamart_user_profile.ultipro_emp_id) if @datamart_user_profile.ultipro_emp_id_changed?

    respond_to do |format|
      if @datamart_user_profile.save
        flash[:success] = 'Loan Officer was successfully updated.'
        format.html { redirect_to core_originator_path(@datamart_user_profile.datamart_user_id) }
        format.json { render json: @datamart_user_profile, status: :created, location: @datamart_user_profile }
      else
        flash[:error] = @datamart_user_profile.errors.full_messages
        format.html { render action: "new" }
        format.json { render json: @datamart_user_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @datamart_user_profile = DatamartUserProfile.where(id: params[:id]).last
  end

  def update
    @datamart_user_profile = DatamartUserProfile.where(id: params[:id]).last

    respond_to do |format|
      if @datamart_user_profile.update_attributes(datamart_user_profile_params, without_protection: true)
        DatamartUserProfile.where(datamart_user_id: @datamart_user_profile.datamart_user_id).update_all(ultipro_emp_id: @datamart_user_profile.ultipro_emp_id) if @datamart_user_profile.ultipro_emp_id_changed?
        flash[:success] = 'Loan Officer was successfully updated.'
        format.html { redirect_to core_originator_path(@datamart_user_profile.datamart_user_id) }
        format.json { render json: @datamart_user_profile, status: :created, location: @datamart_user_profile }
      else
        flash[:error] = @datamart_user_profile.errors.full_messages
        format.html { render action: "edit" }
        format.json { render json: @datamart_user_profile.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @datamart_user_profile = DatamartUserProfile.find(params[:id])
    @datamart_user_profile.destroy

    respond_to do |format|
      format.html { redirect_to core_originator_path(@datamart_user_profile.datamart_user_id) }
      format.json { head :no_content }
    end
  end

private
  def datamart_user_profile_params
    params.require(:datamart_user_profile).permit(:datamart_user_id, :effective_date, :title, :preferred_first_name, :institution_id, :ultipro_emp_id)
  end
end
