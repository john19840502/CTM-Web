class LoanLockExpirationEmail < DatabaseRailway

  def record_emails(lns, dz)

    self.loans = ''
    
    lns.each do |l|
      ln = l.originator
      self.loans << "#{l.loan_num}~#{ln.try(:id).to_s}~#{ln.try(:name).to_s}~#{ln.try(:email).to_s}#{'~No Originator' unless ln}|"
    end

    self.check_days = dz
    self.save

  end

end
