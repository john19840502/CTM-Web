module Core::LoansHelper
  def loan_purpose loan
    if loan.purpose.eql?('REFIPLUS') or loan.purpose.eql?('REFINANCE')
      "#{loan.loan_purpose} - #{loan.loan_purpose_description}" if loan.loan_purpose_description.present?
    else
      loan.loan_purpose
    end
  end

  def header hdr
    html = "<div class='lead'>"
    
    if hdr.present?
      html << "Loans originated "
      html << "at #{link_to_if can?(:read, Institution), "Branch #{hdr.branch_name} :: #{hdr.institution_number}", core_institution_path(hdr)}" if hdr.class.eql?(Institution)
      html << "by #{link_to_if can?(:read, BranchEmployee), hdr.name, core_originator_path(hdr)}" if hdr.class.eql?(BranchEmployee) || hdr.class.eql?(DatamartUser)
    else  
      html << "#{Channel.retail.name}, #{Channel.consumer_direct.name} and #{Channel.private_banking.name} Loans"
    end
    html << "</div>"
    html
  end

  def loan_show_header loan
    branch = loan.loan_general.branch
    originator = loan.loan_general.originator

    html = ""
    
    html << "<div class='lead' style='margin-bottom:0;'>Branch: #{link_to_if can?(:read, Institution), "Branch #{branch.branch_name} :: #{branch.institution_number}", core_institution_path(branch)}</div>" if branch
    html << "<div class='lead'>Originator: #{link_to_if can?(:read, BranchEmployee), originator.name, core_originator_path(originator)}</div>" if originator

    html
  end

  def property_address_field(loan)
    raw "#{loan.property_street}<br />#{loan.property_city}, #{loan.property_state} #{loan.property_zip}"
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
