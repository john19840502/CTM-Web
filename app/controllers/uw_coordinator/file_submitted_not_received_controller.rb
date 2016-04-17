
class UwCoordinator::FileSubmittedNotReceivedController < ApplicationController
  def index
    data.label   = 'UW Submitted Not Received'
    data.model   = UwSubmittedNotReceived
    if params[:sort].blank?
      data.records = data.model.includes(:ctm_loan => :coordinator).order(:uw_submitted_at).all #Keeping at as a scoped results in inconsistencies when things change as the page is loading.
    else
      if params[:sort].downcase == 'amera'
        data.records = data.model.amera_only.includes(:ctm_loan => :coordinator).order(:uw_submitted_at).all #Keeping at as a scoped results in inconsistencies when things change as the page is loading.
      else
        data.records = data.model.ctm_only.includes(:ctm_loan => :coordinator).order(:uw_submitted_at).all #Keeping at as a scoped results in inconsistencies when things change as the page is loading.
      end
    end
    @results     = data.records
    data.columns = [:loan_id, :uw_submitted_at, :age, :coordinator, :channel, :purpose, :borrower_last_name, :is_mi_required, :mortgage_type, :product_code, :is_jumbo_candidate, :property_state]
    respond_to do |format|
      format.html { render 'index-erb' } # switch from haml, which punches babies on large datasets.
      format.xls { send_data data.to_xls }
    end
  end

  def update
    @coordinators = CtmUser.select('id, domain_login')
    uw_submitted_not_received = UwSubmittedNotReceived.find(params[:id])
    uw_submitted_not_received.coordinator_id = params[:uw_submitted_not_received][:coordinator_id]
    render partial: 'coordinator', locals: { record: uw_submitted_not_received }
  end

  def loan_counts
    @date_counts = UwSubmittedNotReceived.date_counts
    @counts_by_channel = UwSubmittedNotReceived.counts_by_channel
  end

  def assign_self
    @uw_submitted_not_received = UwSubmittedNotReceived.find(params[:id])
    @uw_submitted_not_received.ctm_loan.update_coordinator(current_user.try(:ctm_user))
    respond_to do |format|
      if current_user.ctm_user.nil? or current_user.ctm_user.domain_login.blank?
        format.html { render :text => 'No CTM user found in database.', :status => :unprocessable_entity }
      elsif !@uw_submitted_not_received.nil?
        format.html { render :text => current_user.ctm_user.try(:domain_login), :status => :created }
      else
        format.html { render text: 'Unable to assign you to record.', :status => :unprocessable_entity }
      end
    end
  end

end
