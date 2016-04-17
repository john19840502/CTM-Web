class BpmStatisticReport < DatabaseRailway
  APPROVED_STATUS = [
    'Funding Request Received',
    'U/W Approved w/Conditions',
    'U/W Final Approval/Ready for Docs',
    'U/W Final Approval/Ready to Fund',
    'U/W Pre-Approved',
    'Closing Request Received',
    'Docs Out',
  ]
  
  def validation_requests
    @validation_requests ||= find_validation_requests.to_a
  end

  def statistics_hash
    {
      validation_requests: validation_requests, 
      loan_decisions_chart: validation_charts.decision_dates,
      decision_errors_chart: validation_charts.decision_flow_errors,
      approved_errors: approved_with_errors,
      # not_validated_chart: not_validated_chart,
      # not_validated_chart_static: validation_charts.non_valid_loans,
      not_validated_list: not_validated_list,
    }
  end

  def validation_charts
    @validation_charts ||= find_validation_charts
  end

  def loan_decisions_chart
    [ { name: "Initial Decision", 
        data: count_validation_requests_by_type('initial_decision') 
      }, 
      { name: "Final Approval", 
        data: count_validation_requests_by_type('final_approval') 
      } 
    ]
  end

  def decision_errors_chart
    arr = []
    Decisions::Flow::FLOWS.keys.each do |flow|
      arr << {name: flow.to_s, data: count_validation_requests_by_flow(flow.to_s)}  
    end
    arr
  end

  def approved_with_errors
    approved_loan_requests.map do |vr|
      create_error_hash(vr)
    end.flatten.uniq
  end

  def not_validated_chart
    [ 
      { name: "Non-Validated Loans", 
        data: count_unvalidated_loans
      } 
    ]
  end

  def not_validated_list
    non_validated_loans
  end

private 

  def find_validation_charts
    event = Mdb::ValidationCharts.find_or_initialize_by(statistic_report_id: id)
      if event.new_record?
        event.decision_dates = loan_decisions_chart
        event.non_valid_loans = not_validated_chart
        # event.non_valid_loans_list = non_validated_loans
        event.decision_flow_errors = decision_errors_chart
        event.statistic_report_id = id
        event.created_at = DateTime.now
        event.save!
      end
    return event
  end

  def find_validation_requests

    if loan_num.present?
      return Bpm::LoanValidationEvent.where 'loan_num' => loan_num
    end

    find_by_other_criteria
  end
  
  def find_by_other_criteria
    query = Bpm::LoanValidationEvent.all
    if underwriter.present?
      query = query.in('underwriter' => comma_separate(underwriter))
    end

    if validation_errors.present?
      query = query.where('validation_messages.message' => /#{comma_separate(validation_errors).join('|')}/)
    end

    if loan_status_at_validation.present?
      query = query.where('loan_status' => loan_status_at_validation)
    end

    if product_code.present?
      query = query.where('product_code' => product_code)
    end

    if channel.present?
      query = query.where('channel' => channel)
    end

    if region.present?
      query = query.in('property_state' => find_state(region))
    end

    if start_date.present? 
      query = query.where(date: {'$gte' => start_date.to_datetime})
    end
      
    if end_date.present?
      query = query.where(date: {'$lte' => end_date.to_datetime.end_of_day})
    end

    query #.order_by('underwriter ASC')
  end

  def find_state(region)
    case region
    when "NE/Midwest"
      ["CT", "NY", "MA", "MI", "IL", "IN", "ME", "VT", "MN", "WI", "KY", "OH", "RI", "NH"]
    when "SE/Mid-Atlantic"
      ["PA", "GA", "AL", "TN", "FL", "VA", "MO", "KS", "NC", "SC", "NJ", "DE", "DC", "LA", "MD"]
    when "West"
      ["CA", "WA", "OR", "TX", "AZ", "UT", "CO", "HI"]
    else
      ""
    end
  end

  def comma_separate(str)
    str.split(',').map(&:strip).reject(&:empty?)
  end

  def count_validation_requests_by_type(type)
    0    
    # (start_date..end_date).map do |date|
    #   validation_requests.select do |vr| 
    #     vr.try(type.to_sym).to_date == date if vr.try(type.to_sym).present?
    #   end.map(&:loan_status).map(&:loan_num).uniq.size
    # end
  end

  def count_validation_requests_by_flow(flow)
    0
    # (start_date..end_date).map do |date|
    #   validation_requests.select do |vr| 
    #     vr.date.to_date == date &&
    #     vr.validation_type == flow &&
    #     vr.validation_messages.map{ |v| v.type if v.type.include?("error") }.size > 0
    #   end.size
    # end
  end

  def count_unvalidated_loans
    (start_date..end_date).map do |date|
      non_validated_loans.select do |l| 
        if l.initial_decision_date.nil?
          l.final_approval_date.to_date == date
        else
          l.initial_decision_date.to_date == date
        end
      end.size
    end
  end

  def create_error_hash(request)
    hsh = []
    request.validation_messages.select do |vm|
      vm.type == "error" &&
      vm.is_reviewed == false
    end.each do |msg|
      hsh << {
              report_id: self.id, loan_num: request.loan_num, 
              underwriter: request.underwriter, error_msg: msg.message, 
              error_id: msg.id
            }
    end
    hsh
  end

  def find_non_validated_loans
    date1 = (end_date + 1.day).to_datetime
    date2 = start_date.to_datetime
    not_lns = validated_loan_nums
    loans = loans_with_initial_date(date1, date2, not_lns)
    return loans
  end

  def non_validated_loans
    @loans ||= find_non_validated_loans.to_a
  end

  def loans_with_initial_date(date1, date2, not_lns)
    Loan.select(
      [:loan_num, :initial_decision_date, :final_approval_date]
      ).where{
      loan_num.not_in(not_lns)}.where{
      ((initial_decision_date <= date1) & (initial_decision_date > date2)) | 
      ((final_approval_date <= date1) & (final_approval_date > date2))

    }.uniq
  end

  def validated_loan_nums
    validation_requests.map(&:loan_num).uniq
  end

  def remove_common_loans(loans)
    unless loans.empty?
      loans.reject { |x| x.loan_num.in?(validated_loan_nums) }  
    end
  end

  def approved_loan_requests
    # validation_requests.map { |vr| vr if (Array(vr.loan_status) & APPROVED_STATUS) == vr.to_a }.compact
    validation_requests.select do |vr| 
      APPROVED_STATUS.include?(vr.loan_status) 
    end
  end
end
