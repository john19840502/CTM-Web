class CreditSuisseOpsReport < AccountingReport
  require 'write_xlsx'

  before_validation do |record|
    record.name ||= "Credit Suisse Ops Report #{Time.now.strftime('%s')}"
  end


  # def self.generate_report
 
  #   report_date = 1.day.ago.end_of_day

  #   # NOTE: Needed to force these to, to_date, so that they would keep the right days, otherwise EOD
  #   # was being incremented to the next day.
  #   CreditSuisseOpsReport.create(
  #     start_date: report_date,
  #     end_date: Time.now,
  #     name: "Credit Suisse Ops Report #{report_date.strftime('%m/%d/%Y')} #{Time.now.strftime('%s')}"
  #   )
  # end

  def create_attachment

    # will be used for array index to column letter conversion, i.e. @ltrs[ix]
    path = "#{Rails.root}/tmp/credit_suisse_ops_report_#{start_date.strftime('%m_%d_%Y')}_#{Time.now.strftime('%s')}.xlsx"

    # Create a new Excel @workbook
    @workbook = WriteXLSX.new(path)

    #  Add and define a format
    # EACH FORMAT OBJECT is applied only at the END of process, and so any manipulation with it will not have a desired effect.

    @format_main_hdr                          = @workbook.add_format(font: 'Calibri', size: 20, bg_color: '#d8e2ed', bold: 1, top: 1, bottom: 1, left: 1)

    @format_def                               = @workbook.add_format(font: 'Calibri', size: 11)
                        
    @format_bold                              = @workbook.add_format(font: 'Calibri', size: 11, bold: 1)

    @format_curr                              = @workbook.add_format(font: 'Calibri', size: 11, num_format: '$#,###.##')

    # Add a worksheet
    @dp_ws = @workbook.add_worksheet()
    do_report @dp_ws

    @workbook.close

    # self.update_attribute(:bundle, File.open(path))

    # File.delete(path)
    save_attachment(path, true)
  end

  def do_report(ws)

    ws.write_string(0, 0, "Loan Number", @format_bold)
    ws.write_string(0, 1, "Product Code", @format_bold)
    ws.write_string(0, 2, "Lock Date", @format_bold)          
    ws.write_string(0, 3, "Borrower Name", @format_bold)
    ws.write_string(0, 4, "Investor", @format_bold)
    ws.write_string(0, 5, "Investor Loan Number", @format_bold)
    ws.write_string(0, 6, "Suggested Investor", @format_bold)
    ws.write_string(0, 7, "Status", @format_bold)

    loans = LockPrice.where{product_description.like "%jumbo%"}.includes(:loan).map(&:loan).compact
    loans.delete_if {|loan| ['Funded', 'Cancelled', 'Withdrawn', 'Servicing', 'Shipped to Investor', 'Shipping Received', 'Investor Suspened'].include? loan.loan_status }
    
    ix = 2
    loans.each do |l|              
      ws.write_number(ix, 0, l.loan_num, @format_def)
      ws.write_string(ix, 1, l.lock_price.product_code, @format_def)
      ws.write_string(ix, 2, (l.locked_at && (I18n.l l.locked_at)) || 'n/a', @format_def)
      ws.write_string(ix, 3, (l.borrower_first_name + ' ' + l.borrower_last_name), @format_def)
      ws.write_string(ix, 4, l.investor_name || 'n/a', @format_def)
      ws.write_number(ix, 5, l.investor_lock.investor_loan_id, @format_def)
      ws.write_string(ix, 6, l.smds_jumbo_fixed_loan.try(:investor_name) || 'n/a', @format_def)
      ws.write_string(ix, 7, l.loan_status, @format_def)
      ix += 1
    end

  end
end
