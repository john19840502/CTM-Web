require 'csv'

class Compliance::Hmda::PurchasedLoanImporter

  def import_file(input, report_date)
    lines = input.lines
    headers = lines.first.split(',').map!{|h| h.strip.downcase.parameterize.underscore.to_sym}
    data = lines.drop(1).join
    CSV.parse(data, { headers: headers, skip_blanks: true }) do |row|
      handle_row row.to_hash, report_date
    end
  end

  def handle_row row, report_date
    remove_empties row
    ploan = PurchasedLoan.new allowed_parameters(row), without_protection: true

    ploan.dispdate = report_date

    ploan.original_signature = ploan.calculate_data_signature

    ploan.reported = false
    
    unless existing_hashes.include?(ploan.original_signature)
      begin
        ploan.save!
      rescue Exception => e
        raise "#{e.message}"
      end
    end
    loan_numbers << row[:cpi_number].to_s
  end

  def allowed_parameters(row)
    allowed_attributes = PurchasedLoan::attribute_names.map(&:to_sym) - 
      [:id, :created_at, :updated_at, :original_signature, :current_signature, :reported]
    ActionController::Parameters.new(row).permit(*allowed_attributes)
  end

  def existing_hashes
    current_sigs.concat(original_sigs).to_set
  end

  def original_sigs
    PurchasedLoan.pluck(:original_signature)
  end

  def current_sigs
    PurchasedLoan.pluck(:current_signature)
  end

  def loan_numbers
    @loan_numbers ||= PurchasedLoan.pluck(:cpi_number).uniq.map(&:to_s).to_set
  end

  def remove_empties(row)
    row.each do |k,v|
      next if v.nil?
      if v.strip.empty?
        row[k] = nil
      end
    end
  end

end
