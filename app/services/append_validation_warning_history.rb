class AppendValidationWarningHistory
  include ServiceObject

  attr_accessor :warnings, :loan_id

  def initialize warnings, loan_id
    self.warnings = warnings
    self.loan_id = loan_id
  end

  def call
    warnings.map do |warning|
      text = fix_dates_in_message(warning[:text])
      warning.merge history: ValidationAlert.where(loan_id: loan_id, text: text).order('created_at desc').map(&:as_json)
    end
  end

  private

  def fix_dates_in_message(txt)
    txt.scan(/\d+00000/).each do |dt|
      txt.gsub!(dt, Time.at(dt.to_i/1000).strftime('%-m/%-d/%Y')) if dt.to_i > 1343145500000
    end
    txt
  end
end
