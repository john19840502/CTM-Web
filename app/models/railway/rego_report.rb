class RegoReport < AccountingReport

  require 'write_xlsx'

  def self.generate_report
 
    report_date = 1.day.ago.end_of_day

    # NOTE: Needed to force these to, to_date, so that they would keep the right days, otherwise EOD
    # was being incremented to the next day.
    RegoReport.create(
      start_date: report_date,
      end_date: Time.now,
      name: "Rego Report #{report_date.strftime('%m/%d/%Y')} #{Time.now.strftime('%s')}"
    )
  end

  def create_attachment

    # will be used for array index to column letter conversion, i.e. @ltrs[ix]
    path = "#{Rails.root}/tmp/rego_report_#{start_date.strftime('%m_%d_%Y')}_#{Time.now.strftime('%s')}.xlsx"

    # Create a new Excel @workbook
    @workbook = WriteXLSX.new(path)

    #  Add and define a format
    # EACH FORMAT OBJECT is applied only at the END of process, and so any manipulation with it will not have a desired effect.

    @format_main_hdr                          = @workbook.add_format(font: 'Calibri', size: 20, bg_color: '#d8e2ed', bold: 1, top: 1, bottom: 1, left: 1)

    @format_def                               = @workbook.add_format(font: 'Calibri', size: 11)
                        
    @format_bold                              = @workbook.add_format(font: 'Calibri', size: 11, bold: 1)

    @format_dec                               = @workbook.add_format(font: 'Calibri', size: 11, num_format: '0.000')

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
    ws.write_string(0, 1, "Borrower Name", @format_bold)
    ws.write_string(0, 2, "Current Address", @format_bold)          
    ws.write_string(0, 3, "Phone Number", @format_bold)          
    ws.write_string(0, 4, "Email Address", @format_bold)          
    ws.write_string(0, 5, "Social Security #", @format_bold)          
    ws.write_string(0, 6, "Executives, Directors, and Related Parties", @format_bold)
    ws.write_string(0, 7, "Match Score", @format_bold)
    ws.write_string(0, 8, "Employee Loan?", @format_bold)

    fuzzy = FuzzyStringMatch::JaroWinkler.create(:native)
    ctm_execs_l = CtmExecs.all.map { |ce| "#{ce.last}" }
    ctm_execs_f = CtmExecs.all.map { |ce| "#{ce.first}" }
    @loans = LoanFactDaily.where(:loan_status => ['U/W Conditions Pending Review', 'U/W Approved w/Conditions', 'U/W Final Approval/Ready to Fund', 'New', 'U/W Final Approval/Ready for Docs', 'U/W Suspended', 'Submitted', 'Imported', 'Closing Request Received', 'U/W Submitted', 'U/W Received'])

    ix = 2
    
    CtmExecs.all.each do |ce|
      @loans.where(borrower_last_name: ce.last_name).each do |l|
        address = l.loan_general.borrower_addresses.find_by_borrower_last_name(ce.last_name)
        score = fuzzy.getDistance(ce.first_name, l.borrower_first_name)
        if score > 0.96

          ws.write_string(ix, 0, l.id, @format_def)
          ws.write_string(ix, 1, address.borrower_first_last_name, @format_def) 
          ws.write_string(ix, 2, "#{address.current_street_address}" "#{address.current_city_state_zip}", @format_def)  
          ws.write_string(ix, 3, address.home_tele_num, @format_def)     
          ws.write_string(ix, 4, address.email, @format_def)      
          ws.write_string(ix, 5, address.ssn[-4, 4], @format_def)         
          ws.write_string(ix, 6, "#{ce.first_name}" + " " + "#{ce.last_name}", @format_def)
          ws.write_number(ix, 7, score.round(3), @format_dec)
          ws.write_string(ix, 8, l.loan_general.additional_loan_datum.employee_loan_indicator.to_s, @format_def)
          ix += 1
        end
      end

    end

  end
end
