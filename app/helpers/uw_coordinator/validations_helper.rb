module UwCoordinator::ValidationsHelper
  def bullet(type)
    
    case type
    when 'yes_or_no'
      'oh hi'
    else
      nil
    end
  end
  
  def escrow_waiver_field(loan)
    "LOAN: #{truth_as_yes_no loan.is_escrow_waived}
     <br/>
     LOCK: #{truth_as_yes_no loan.locked_loan_snapshot.is_escrow_waived rescue nil}"
  end
  
  def borrower_last_name_field(loan)
    h loan.borrowers.first.last_name rescue '[ERROR]'
  end
  
  def borrower_first_name_field(loan)
    h loan.borrowers.first.first_name rescue '[ERROR]'
  end
    
  def underwriter_name_field(loan)
    if loan.loan_general.loan_assignees.underwriter.blank?
      last_to_access = loan.read_last_note('UnderwriterAccess')
      "#{last_to_access.body} at #{last_to_access.created_at.in_time_zone('Eastern Time (US & Canada)').strftime('%m/%d/%Y %I:%S %p')}"
    else
      "UNDERWRITER: #{loan.loan_general.loan_assignees.underwriter.first.first_name} #{loan.loan_general.loan_assignees.underwriter.first.last_name}"
    end
  end

  def property_address_field(loan)
    raw "#{loan.property_street}<br />#{loan.property_city}, #{loan.property_state} #{loan.property_zip}"
  end

  def warning_flag(loan_id, msg)
    if msg.class.eql?(String)
      _id = 0
      _msg = msg
      flag = ValidationAlert.find_by_loan_id(loan_id)
    else
      _id = msg[0]
      _msg = msg[1]
      flag = ValidationAlert.find_by_loan_id_and_rule_id(loan_id, msg[0])
    end

    if loan_id
      content_tag :li, 
        id: "msg#{_id}", 
        class: 'message' do
        if flag
          raw "<img src='#{root_url}/assets/icon_sets/famfamfam_silk/icons/flag_green.png' />&nbsp;Completed by #{flag.user_name} on #{flag.updated_at.strftime('%m/%d/%Y')} :: #{_msg}"
        else
          raw "<a onclick='App.process_registration_validation_alerts(\"#{process_registration_validation_alert_uw_coordinator_validations_path(lid: loan_id, rid: _id)}\");' href='#'><img src='#{root_url}/assets/icon_sets/famfamfam_silk/icons/flag_red.png' /></a>&nbsp;#{_msg}"
        end
      end
    end
  end

  def project_classification loan
    pc = loan.try(:loan_feature).try(:fnm_project_classification_type)
    if pc.blank?
      if loan.loan_general.mortgage_term and %w(FHA VA).include?(loan.loan_general.mortgage_term.mortgage_type)
        return 'N/A for this mortgage type'
      end
    else
      return pc
    end
    return 'Not Found'
  end

  def pdf_image name
    wicked_pdf_image_tag(name)
  end

  def apr_delta loan, uwr
    if uwr and loan.loan_general.additional_loan_datum and
      uwr.prior_apr.present? and uwr.prior_apr > 0 and
      loan.loan_general.additional_loan_datum.apr.present?
      number_with_precision((loan.loan_general.additional_loan_datum.apr) - (uwr.prior_apr), precision: 3)
    else
      ''
    end
  end
end
