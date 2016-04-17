class LoanComplianceExceptionReport < AccountingReport

  require 'write_xlsx'
  
  before_validation do |record|
    record.name ||= "Loan Compliance Exception Report #{Time.now.strftime('%s')}"
  end

  def create_attachment
    # will be used for array index to column letter conversion, i.e. @ltrs[ix]
    start_date = Date.today
    path = "#{Rails.root}/tmp/loan_compliance_exception_report_#{start_date.strftime('%m_%d_%Y')}_#{Time.now.strftime('%s')}.xlsx"

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
    save_attachment(path, true)
  end

  def do_report(ws)

    ws.write_string(0, 0, "APLNNO", @format_bold)
    ws.write_string(0, 1, "ID", @format_bold)
    ws.write_string(0, 2, "COLUMN NAME", @format_bold)
    ws.write_string(0, 3, "EXCEPTION VALUE", @format_bold)
    ws.write_string(0, 4, "RECONCILED VALUE", @format_bold)
    ws.write_string(0, 5, "RECONCILED BY", @format_bold)
    ws.write_string(0, 6, "RECONCILED DATE", @format_bold)
    

    loans = LoanComplianceEvent.all.keep_if{|l| l.exception_history.present?}

    ix = 1
    last_ap_num = nil
    loans.group_by(&:aplnno).each do |ap, ap_id|
      ap_id.group_by(&:id).each do |id, l_id|
        l_id.each do |l|
          l.exception_history.each do |eh|
            ws.write_number(ix, 0, (ap.to_s == last_ap_num.to_s) ? '' : ap, @format_def)
            ws.write_number(ix, 1, id, @format_def)
            ws.write_string(ix, 2, eh[0], @format_def)
            ws.write(ix, 3, eh[1][0].to_s, @format_def)
            ws.write(ix, 4, eh[1][1].to_s, @format_def)
            ws.write_string(ix, 5, l.reconciled_by, @format_def)
            ws.write_string(ix, 6, l.reconciled_at.to_datetime.strftime(I18n.t("datetime.formats.checklist")), @format_def)
            
            ix += 1
            last_ap_num = ap
          end
        end
      end 
    end
  end
end
