module AllongeHelper

  def format_address(loan)
    a = loan.property_address
    b = loan.property_city
    pc = loan.property_postal_code
    if pc.length == 9
      pc = "#{pc[0,5]}-#{pc[5,4]}"
    end
    c = "#{loan.property_state} #{pc}"
    [a,b,c].reject(&:blank?).join ", "
  end

  def all_borrowers(loan)
    loan.borrowers.map(&:full_name).join(' and ')
  end

  def successor_to(loan, successors)
    Rails.logger.debug successors.inspect
    successors[loan.loan_num]
  end
end
