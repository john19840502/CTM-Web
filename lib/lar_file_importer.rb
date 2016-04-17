require 'csv'

class Compliance::Hmda::LarFileImporter

  # LAR = Loan Activity Report; it is a document that the Compliance department 
  # produces periodically for government regulators to document our compliance
  # with fair lending laws such as CRA and HMDA.  This controller is for 
  # importing a LAR document produced by MortgageBot that gets things mostly right.  
  # We do some transformations as part of the import process, and provide screens
  # for Compliance folks to make further corrections based on their research, 
  # before producing a "final" LAR suitable for importing into other programs, such
  # as CRA Wiz.  

  def initialize(progress_sink = nil)
    @progress_sink = progress_sink
  end

  def import_file(file_upload)
    file = File.open(file_upload.hmda_loans.path).read
    report_date = LoanComplianceEventUpload.last.period_dates
    input_file_import(file, file_upload.id, report_date)
  end

  def input_file_import(input, file_id, report_date)
    lines = input.lines
    headers = lines.first.split(',').map!{|h| h.strip.downcase.parameterize.underscore.to_sym}
    data = lines.drop(1).join
    row_num = 0

    raise @errors.join('~') unless file_is_valid?(data, headers, lines.count, report_date)

    CSV.parse(data, { headers: headers.delete_if(&:empty?), skip_blanks: true }) do |row|
      row_num += 1
      count = lines.count
      begin
        handle_row row.to_hash, file_id
        notify_progress((row_num.to_f + count.to_f)/(2*count.to_f)*100)
      rescue Exception => e
        raise "Line #{row_num}: #{e.message}"
      end
    end
  end

  def do_transformations row, loan
    
    translate_race_fields row

  end

  private

  def handle_row row, file_id
    loan = Loan.find_by_loan_num row[:aplnno]
    @employee_loan = loan.try(:loan_general).try(:additional_loan_datum).try(:employee_loan_indicator)
    
    remove_empties row
    remove_undesired_fields row
    format_dates row

    event = LoanComplianceEvent.new row
    event.employee_loan = @employee_loan
    event.non_existant_loan = loan.nil?

    if event.non_existant_loan
      event.reportable = false
      event.comments = "Test Loan"
    else
      event.reportable = true
    end

    event.loan_compliance_event_upload_id = file_id
    event.transformed = false
    
    event.original_signature = event.calculate_data_signature
    
    unless existing_hashes.include?(event.original_signature)
      begin
        event.save!
      rescue Exception => e
        raise "#{event.apr} :: #{e.message}"
      end
    end
    loan_numbers << row[:aplnno].to_s
  end

  def existing_hashes
    current_sigs.concat(original_sigs).to_set
  end

  def original_sigs
    LoanComplianceEvent.pluck(:original_signature)
  end

  def current_sigs
    LoanComplianceEvent.pluck(:current_signature)
  end

  def loan_numbers
    @loan_numbers ||= LoanComplianceEvent.pluck(:aplnno).uniq.map(&:to_s).to_set
  end

  def remove_undesired_fields row
    [:subincl, :treasec, nil].each { |key| row.delete key }
  end

  def format_dates row
    [:apdate, :actdate, :lockdate, :createdate].each do |key|
      next unless row[key].present? 
      row[key] = Chronic.parse(row[key]).to_date
    end
    row[:finaldate] = Chronic.parse(row[:finaldate]) if row[:finaldate].present?
  end

  def file_is_valid? data, headers, count, report_date
    file_is_valid = true
    @errors = []
    row_num = 0

    CSV.parse(data, { headers: headers.delete_if(&:empty?), skip_blanks: true }) do |row|
      row_num += 1
      row_hash = row.to_hash

      remove_empties row_hash
      remove_undesired_fields row_hash
      format_dates row_hash
      # translate_race_fields row_hash

      event = LoanComplianceEvent.new(row_hash)
      # actdt = Date.strptime(row_hash[:actdate], '%m/%d/%Y').try(:beginning_of_month)
      actdt = event.actdate.beginning_of_month

      if !actdt.in?(report_date)
        file_is_valid = false 
        @errors << "Line #{row_num}, aplnno: #{event.aplnno}, Errors: actdate - #{event.actdate.present? ? actdt.strftime('%m/%d/%Y') : 'NOT PROVIDED'} is outside selected report period"
      elsif event.invalid?
        file_is_valid = false 
        @errors << "Line #{row_num}, aplnno: #{event.aplnno}, Errors: #{event.errors.full_messages.join('; ')}"
      end

      notify_progress(row_num.to_f/(2*count.to_f)*100)
    end    
    file_is_valid
  end

  def remove_empties(row)
    row.each do |k,v|
      next if v.nil?
      if v.strip.empty?
        row[k] = nil
      end
    end
  end

private
  attr_reader :progress_sink

  def notify_progress percent
    return unless progress_sink
    progress_sink.notify(percent)
  end

end

