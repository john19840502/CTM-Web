class Smds::DmiTrialBalByInvestorsController < ApplicationController
  skip_before_filter :verify_authenticity_token # The CSRF token thing messes up the file import.

  def index
    data.model = model
    data.server_side = true

    flash[:notice] = "P181 File is currently being imported" if Delayed::Job.where(queue: Smds::P181FileImport::QUEUE_NAME).where(failed_at: nil).any?

    respond_to do |format|
      format.html
      format.json { render json: data.as_json(params) }
    end
  end

  def new
    flash[:notice] = "P181 File is currently being imported" if Delayed::Job.where(queue: Smds::P181FileImport::QUEUE_NAME).where(failed_at: nil).any?
    @dmi_trial = model.new
  end

  def create
    if params[:smds_dmi_trial_bal_by_investor].blank? || params[:smds_dmi_trial_bal_by_investor][:file].blank?
      errors = "File was not uploaded, please try again"
    else
      errors = model.import_file(params[:smds_dmi_trial_bal_by_investor][:file])
    end
    redirect_to preview_smds_dmi_trial_bal_by_investors_url, flash_for_errors(errors)
  end

  def preview
    flash[:notice] = "P181 File is currently being imported" if Delayed::Job.where(queue: Smds::P181FileImport::QUEUE_NAME).where(failed_at: nil).any?
    @old_data = model.old_data
    @new_data = Smds::P181FileImport.new_data
  end

  def import
    model.create_from_file
    redirect_to smds_dmi_trial_bal_by_investors_url, flash: { success: "File is now being imported!" }
  end

  private

  def flash_for_errors(error_message)
    status_message =
        if error_message
          { error: error_message }
        else
          { success: "File is ready to be imported!" }
        end
    { flash: status_message }
  end

  def model
    Smds::DmiTrialBalByInvestor
  end
end