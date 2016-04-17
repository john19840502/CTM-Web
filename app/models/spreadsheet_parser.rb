require 'csv'
require 'roo'
 
class SpreadsheetParser
  
  def self.parse(file)
    name = file.path.to_s
    if name =~ /\.csv/
      CSV::Reader.parse(file).each do |row|
        yield row
      end
    else
      roo = build_roo_wrapper(name)
      roo.default_sheet = roo.sheets.first
      1.upto(roo.last_row) do |line|
        row = []
        1.upto(roo.last_column) do |column|
          row << roo.cell(line,column)
        end
        yield row
      end
    end
  end
 
protected
  def self.build_roo_wrapper(name)
    roo = nil
    if name =~ /\.xlsx/
      roo = Roo::Excelx.new(name)
    elsif name =~ /\.xls/
      roo = Roo::Excel.new(name)
    elsif name =~ /\.ods/
      roo = Roo::Openoffice.new(name)
    else
      raise "Cannot parse this file, unrecognized format"
    end
    roo
  end
  
end
