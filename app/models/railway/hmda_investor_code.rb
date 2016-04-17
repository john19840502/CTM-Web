class HmdaInvestorCode < DatabaseRailway
  serialize :investor_name, Array

  def self.investor_hash
    h = Hash.new
    self.all.each do |i|
      h[i.investor_code] = i.investor_name
    end
    h
  end

  def self.investor_list
    hmda_investor_names = HmdaInvestorCode.select(:investor_name).map(&:investor_name).flatten
    # loan_investor_names = Loan.select(:investor_name).uniq.map(&:investor_name)
    loan_investor_names = InvestorLock.unique_names
    (loan_investor_names - hmda_investor_names).reject { |i| i.empty? }
  end

  @@investor_codes = nil
  def self.investor_codes
    @@investor_codes ||= investor_hash
  end

  def self.update_code(code, investor)
    invest_code = self.find_by(investor_code: code) || self.create!({investor_code: code}, without_protection: true)
    if invest_code.new_record?
      invest_code.investor_name = investor.to_a
      invest_code.save!
    else
      invest_code.add_investor(investor)
    end
  end

  def add_investor(investor)
    self.investor_name << investor
    self.save
  end

  def self.existing_codes
    self.select(:investor_code).map(&:investor_code)
  end 
end
