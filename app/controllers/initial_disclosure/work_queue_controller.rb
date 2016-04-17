class InitialDisclosure::WorkQueueController < RestrictedAccessController
  
  def index

    normal_loans = InitialDisclosureTracking.loans_visible_in_queue
    stupid_loans = InitialDisclosureTracking.stupid_loans

    @loans = stupid_loans.concat normal_loans
    # Mini corr loans have to be excluded from the disclosure queue. Mini corr loans starts with 8
    @loans = @loans.reject{|l| l.loan_num.starts_with?("8")}
  end

  def assign_other
    unless view_context.work_queue_assign_other?
      render json: {message: "Permission Denied"}, status: 401
      return
    end

    tracking = find_or_create_tracking(params[:id])
    raise "Failed to find or create tracking info" unless tracking

    tracking.assign_to    = params[:assignee]
    tracking.assigned_by  = current_user.uuid
    tracking.assigned_on  = Time.now
    tracking.save!

    render text: tracking.assign_to, status: :ok
  rescue => e
    handle_json_error_response e
  end

  def assign_self
    unless view_context.work_queue_self_assign?
      render json: {message: "Permission Denied"}, status: 401
      return
    end

    tracking = find_or_create_tracking(params[:id])
    raise "Failed to find or create tracking info" unless tracking

    tracking.assign_to    = current_user.display_name
    tracking.assigned_by  = current_user.uuid
    tracking.assigned_on  = Time.now
    tracking.save!

    render text: tracking.assign_to, status: :ok
  rescue => e
    handle_json_error_response e
  end

  def save_status
    tracking = find_or_create_tracking(params[:id])
    raise "Failed to find or create tracking info" unless tracking

    tracking.status_updated_at = Time.now
    tracking.wq_loan_status    = params[:status]
    tracking.save!
    tracking.update_visibility!

    render json: {}, status: :ok
  rescue => e
    handle_json_error_response e
  end

  def save_title_quote
    tracking = find_or_create_tracking(params[:id])
    raise "Failed to find or create tracking info" unless tracking

    tracking.initial_title_quote_received = params[:initial_title_quote_received]
    tracking.save!

    render json: {}, status: :ok
  rescue => e
    handle_json_error_response e

  end

  private

  def find_or_create_tracking loan_num
    InitialDisclosureTracking.find_by(loan_num: loan_num) ||
      InitialDisclosureTracking.new({loan_num: loan_num}, without_protection: true)
  end
end
