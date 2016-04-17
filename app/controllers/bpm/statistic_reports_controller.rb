require 'bpm/report_csv_dumper'

class Bpm::StatisticReportsController < RestrictedAccessController
  load_and_authorize_resource class: BpmStatisticReport

  def index
    @bpm_statistic_report = BpmStatisticReport.new
    @bpm_prior_searches = BpmStatisticReport.where(:user_uuid => current_user.uuid).order('created_at desc').limit(5)
  end

  def create
    @bpm_statistic_report = BpmStatisticReport.new(bpm_statistic_report_params)
    @bpm_statistic_report.user_uuid = current_user.uuid
    @bpm_statistic_report.end_date = end_date
    @bpm_statistic_report.start_date = end_date.to_date - 9.days
    @bpm_statistic_report.save!

    respond_to do |format|
      format.json {render :json => @bpm_statistic_report}
    end
  
  end
  
  def show
    @bpm_statistic_report = BpmStatisticReport.find(params[:id])
    @bpm_prior_searches = BpmStatisticReport.where(:user_uuid => current_user.uuid).order('created_at desc').limit(5)

    respond_to do |format|
      format.json {
        render :json => 
          @bpm_statistic_report
            .as_json.merge(statistics_hash: @bpm_statistic_report.statistics_hash)
      }
      format.xls
    end
  end

  def export
    report = BpmStatisticReport.find(params[:id])
    csv = Bpm::ReportCsvDumper.new.dump report

    send_data csv,
      type: 'text/csv; charset=utf89; header=present',
      disposition: "attachment; filename=export_query#{params[:id]}.csv"
  end

  def update
    @bpm_statistic_report = BpmStatisticReport.find(params[:id])
    @bpm_statistic_report.update_attributes(bpm_statistic_report_params)

    respond_to do |format|
      format.json {render :json => @bpm_statistic_report}
    end
    # redirect_to @bpm_statistic_report
  end

  def prior_searches
    @bpm_prior_searches = BpmStatisticReport.where(:user_uuid => current_user.uuid).order('created_at desc').limit(5)

    respond_to do |format|
      format.json { render :json => @bpm_prior_searches.as_json }
    end
  end

  def mark_as_reviewed
    report = BpmStatisticReport.find(params[:report_id])
    error_id = params[:error_id]
    error_msg = report.validation_requests.map(&:validation_messages).flatten.map { |x| x if x.id.to_s == error_id }.compact.first
    error_msg.is_reviewed = !error_msg.is_reviewed
    error_msg.reviewed_by = "#{current_user.first_name} #{current_user.last_name}"
    error_msg.reviewed_at = DateTime.now
    error_msg.save!

    render json: nil, status: :ok
  end
  
  def underwriters
    search = "#{params[:term]}%"
    render json: 
      DatamartUser.where("is_active = 1 and user_role_name = ? and (last_name like ? or first_name like ?)", 'Underwriter', search, search).limit(10).map(&:name)
  end

  def validation_errors
    search = Regexp.new("(?i:#{params[:term]})")
    render json: 
      Mdb::LoanValidation.all.collection.aggregate({'$unwind' => '$loan_validation_events'},{'$unwind' => '$loan_validation_events.loan_validation_event_details'},{'$unwind' => '$loan_validation_events.loan_validation_event_details.error_base_messages'},{'$match' => {'loan_validation_events.loan_validation_event_details.error_base_messages' => { '$in' => [search]}}},{'$project' => {'value' => '$loan_validation_events.loan_validation_event_details.error_base_messages', '_id' => 0}}).uniq
  end

private
  def bpm_statistic_report_params
    params.require(:bpm_statistic_report).permit(:user_uuid, :loan_num, :product_code, :start_date, :end_date, :underwriter, :channel, :validation_errors, :state, :loan_status_at_validation)
  end

  def end_date
    return params[:bpm_statistic_report][:end_date] unless params[:bpm_statistic_report][:end_date].blank?
    Date.today
  end
end
