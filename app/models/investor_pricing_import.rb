class InvestorPricingImport < ActiveRecord::Base

  self.table_name = 'ctm.secondary_pricing_imports'

  def self.parse_file(file)
    saved_file = make_temp_file(file)
    column_names = []
    transaction do
      self.delete_all
      SpreadsheetParser.parse(saved_file) do |row|
        if column_names.blank?
          column_names = row
        else
          h = Hash[column_names.zip(row)]
          new_price = self.new
          new_price.from_hash(h)
        end
      end
      self.execute_procedure('ctm.usp_insert_secondary_pricing') if Rails.env.production? || Rails.env.qa?
    end
  end

  def self.make_temp_file(uploaded_file)
    text = uploaded_file.read
    file = Tempfile.new([uploaded_file.original_filename, '.xlsx'], encoding: 'ascii-8bit')
    file.write(text)
    file.rewind
    file
  end

  def from_hash(h)
    self.pricing_date = Time.now
    self.pricing_id = h['Pricing ID']
    self.note_rate = h['Yield.AdjustedNoteRate']
    self.lock_days = h['LockDays']
    self.price = h['Price.Total']
    self.lock_days2 = h['LockDays (2)']
    self.price2 = h['Price.Total (2)']
    self.lock_days3 = h['LockDays (3)']
    self.price3 = h['Price.Total (3)']
    self.lock_days4 = h['LockDays (4)']
    self.price4 = h['Price.Total (4)']
    self.save
  end

end
