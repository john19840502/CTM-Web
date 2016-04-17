require 'csv'

class Compliance::Hmda::HmdaMassUpdate

  def initialize(file, header)
    @file = file
    @header = header.to_sym
  end

  def mass_update
    null_changed_values_column
    lines = @file.lines
    headers = lines.first.split(',').map!{|h| h.strip.downcase.parameterize.underscore.to_sym}
    if headers.include?(@header) || 
      (@header.to_s.eql?('geocode') && ([:macode, :stcode, :cntycode, :censustrct] - headers).empty?) ||
      (@header.to_s.eql?('address') && ([:propstreet, :propcity, :propstate, :propzip] - headers).empty?)

      data = lines.drop(1).join
      row_num = 0

      CSV.parse(data, { headers: headers, skip_blanks: true }) do |row|
        row_num += 1
        count = lines.count
        begin
          handle_row row.to_hash
        rescue Exception => e
          message = Notifier.loan_compliance_event_upload_failure(e.message)
          Email::Postman.call message
          raise "Line #{row_num}: #{e.message}"
        end
      end
      message = Notifier.loan_compliance_event_upload_success
      Email::Postman.call message
    else
      message = Notifier.loan_compliance_event_upload_failure("Headers do not match.")
      Email::Postman.call message
      raise "Header name does not match file import header."
    end
    
  end

  def handle_row row
    # l = LoanComplianceEvent.unexported.where(aplnno: row[:aplnno]).last
    l = LoanComplianceEvent.where(aplnno: row[:aplnno]).last
    if l.present?
      if @header.to_s.eql?('geocode')
        l[:macode] = row[:macode]
        l[:cntycode] = row[:cntycode]
        l[:stcode] = row[:stcode]
        l[:censustrct] = row[:censustrct]
      elsif @header.to_s.eql?('address')
        l[:propstreet] = row[:propstreet]
        l[:propcity] = row[:propcity]
        l[:propstate] = row[:propstate]
        l[:propzip] = row[:propzip]
      else
        l[@header] = row[@header]
      end
      l.save_changed_values
      l.save!
    else
      raise "Loan #{row[:aplnno]} does not exist."
    end
  end

  def null_changed_values_column
    LoanComplianceEvent.update_all(changed_values: nil )
  end

end