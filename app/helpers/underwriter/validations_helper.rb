module Underwriter::ValidationsHelper
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
    raw "#{loan.property_street}<br />#{loan.property_city}, #{loan.property_state} #{loan.property_zip}<br />#{loan.property_county} County"
  end

  def warning_flag(loan_id, msg)
    flag = ValidationAlert.find_by_loan_id_and_rule_id(loan_id, msg[0])
    if flag
      raw "<li id='msg#{msg[0]}' class='message' style='background: url(/assets/icon_sets/famfamfam_silk/icons/flag_green.png) left center no-repeat;padding-left: 20px;'>Completed by #{flag.user_name} on #{flag.updated_at.strftime('%m/%d/%Y')} :: #{msg[1]}</li>" if loan_id
    else
      raw "<li id='msg#{msg[0]}' class='message'><a onclick='App.process_validation_alerts(\"#{process_validation_alert_underwriter_validations_path(lid: loan_id, rid: msg[0])}\");' href='#'><img src='/assets/icon_sets/famfamfam_silk/icons/flag_red.png' /></a>&nbsp;#{msg[1]}</li>" if loan_id
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
end
