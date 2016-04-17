class LoanComplianceEventUploadPeriod < DatabaseRailway
  def period_name
    "#{Date::MONTHNAMES[self.month]} #{self.year}"
  end

  def period_date
    DateTime.civil(self.year, self.month, 1)
  end
end