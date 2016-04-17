class BranchCommissionReport < AccountingReport

  validates_attachment_content_type :bundle, content_type: /xlsx/

  before_validation do |record|
    end_of_month = Time.days_in_month(report_month.to_i, report_year.to_i)
    @report_period = report_period.to_i
    case @report_period
      when 1
        record.start_date = Date.new(report_year.to_i, report_month.to_i, 1)
        record.end_date = Date.new(report_year.to_i, report_month.to_i, 15)
        report_dates = '1-15'
      when 2
        record.start_date = Date.new(report_year.to_i, report_month.to_i, 16)
        record.end_date = Date.new(report_year.to_i, report_month.to_i, end_of_month)
        report_dates = "16-#{end_of_month}"
      when 3
        record.start_date = Date.new(report_year.to_i, report_month.to_i, 1)
        record.end_date = Date.new(report_year.to_i, report_month.to_i, end_of_month)
        report_dates = "1-#{end_of_month}"
    end

    record.name ||= "Retail Branch Commission Report #{Date::ABBR_MONTHNAMES[report_month.to_i]} #{report_dates} #{Time.now.strftime('%s')}"
  end

  def create_attachment
    require 'write_xlsx'

    path = "#{Rails.root}/tmp/#{name}.xlsx"

    # Create a new Excel workbook
    workbook = WriteXLSX.new(path)

    # Add a worksheet
    ws = workbook.add_worksheet

    font = {font: 'Calibri', size: 11}

    #  Add and define a format
    # EACH FORMAT OBJECT is applied only at the END of process, and so any manipulation with it will not have a desired effect.
    format_hdr = workbook.add_format(font) # Add a format
    format_hdr.set_bg_color('#CCCCCC')
    format_hdr.set_right(1)
    format_hdr.set_bottom(1)

    format_def = workbook.add_format(font) # Add a format

    format_bold = workbook.add_format(font) # Add a format
    format_bold.set_bold

    format_curr = workbook.add_format(font) # Add a format
    format_curr.set_align('right')
    format_curr.set_num_format('$#,##0.00')

    format_num = workbook.add_format(font) # Add a format
    format_num.set_align('right')
    format_num.set_num_format('######')

    format_percent = workbook.add_format(font) # Add a format
    format_percent.set_align('right')
    format_percent.set_num_format('0.000%')

    format_dt = workbook.add_format(font) # Add a format
    format_dt.set_align('right')
    format_dt.set_num_format('dd-mmm-yy')

    format_curr_tot = workbook.add_format(font) # Add a format
    format_curr_tot.set_align('right')
    format_curr_tot.set_num_format('$#,##0.00')
    format_curr_tot.set_bold

    format_col_draw = workbook.add_format(font)
    format_col_draw.set_num_format('$#,##0.00;[Red]($#,##0.00)')
    format_col_draw.set_align('right')
    format_col_draw.set_bold

    format_err = workbook.add_format(font) # Add a format
    format_err.set_color('red')
    format_err.set_bold

    # Not sure if this is such a helpful idea... but I wanted to centralize definition of columns... 
    cols = [
            {header: 'AccountNumber', width: 10}, 
            {header: 'Name', width: 30},
            {header: 'OriginalBalance', width: 15, cell_format: format_curr},
            {header: 'FundingDate', width: 10, cell_format: format_dt},
            {header: 'UltiPro Emp. ID', width: 10},
            {header: 'Originator', width: 30},
            {header: 'OriginatingBranch', width: 30},
            {header: 'Branch #', width: 10},
            {header: 'BP Commission', width: 10, cell_format: format_percent},
            {header: 'Gross Commission', width: 10, cell_format: format_curr},
            {header: 'Draw',width: 10, cell_format: format_col_draw},
            {header: 'Net Commission', width: 10, cell_format: format_curr},
            {header: 'Warning Flags', width: 30, cell_format: format_curr}
          ]


    # Printing Headers
    cols.each_with_index do |hdr, col|
      ws.set_column(col, col, hdr[:width], (hdr[:cell_format] || format_def))
      ws.set_row(0, nil, format_hdr)
      ws.write(0, col, hdr[:header])
    end

    # variable "row" is used by me as an index for a 0-based collection of rows in Excel document. 
    # In other words row = Line Number of actual Row - 1
    row = 0

    # Grabbing all active retail loan officers
    # report_period_loans = Master::Loan.where(funded_at: start_date..end_date).where(channel: Channel.retail_all_ids)

    BranchEmployee.retail.sort_by(&:last_name).each do |lo|

      report_period_loans_for_lo = lo.loans.where("funded_at >= ? and funded_at <= ?", start_date.beginning_of_month, end_date.end_of_month).
                                            where(channel: Channel.retail_all_ids)

      lo_total_funded_amount_for_period = report_period_loans_for_lo.sum(:original_balance)

      if lo_total_funded_amount_for_period > 0

        # writing out all loans for a given loan officer
        report_period_loans_for_lo.where("funded_at >= ? and funded_at <= ?", start_date, end_date).group_by(&:branch).each do |branch, loans|

          lo_loan_compensation = lo.compensation_details_for_branch_and_date(branch.id, end_date)
          tiered_amount = lo_loan_compensation.try(:tiered_amount)

          total_funded_for_period_and_branch = report_period_loans_for_lo.where(institution_identifier: branch.institution_number).map(&:original_balance).sum()

          if total_funded_for_period_and_branch > 0 or (end_date.end_of_month.eql?(end_date) and (tiered_amount.present? and total_funded_for_period_and_branch > tiered_amount))

            row = row + 1

            if total_funded_for_period_and_branch > 0

              loans.each do |loan|

                # LO is a BranchEmployee
                lo_loan_specific_compensation = lo.compensation_details_for_branch_and_date(branch.id, loan.funded_at)

                ws.write(row, 0, loan.loan_num, (cols[0][:cell_format] || format_def))
                ws.write(row, 1, borrower_name(loan))
                ws.write(row, 2, loan.original_balance, (cols[2][:cell_format] || format_def))
                ws.write_date_time("D#{row+1}", loan.funded_at.strftime('%Y-%m-%d'), (cols[3][:cell_format] || format_def)) if loan.funded_at
                ws.write(row, 5, lo.name_last_first)
                ws.write(row, 6, branch.branch_name)
                ws.write(row, 7, branch.institution_number)

                broker_replacements = loan.broker_replacement_comments
                report_format = broker_replacements.blank? ? format_def : format_err
                
                comm_percent = calc_percent(lo_loan_specific_compensation.try(:commission_percentage))
                ws.write(row, 8, comm_percent, (cols[8][:cell_format] || format_def))
                row_real = row + 1
                ws.write(row, 9, calc_commission(loan, lo_loan_specific_compensation, comm_percent, lo), (cols[9][:cell_format] || format_def))

                unless broker_replacements.blank?
                  ws.write(row, 12, 'Loan Officer Changed', report_format) 
                  ws.write(row, 13, broker_replacements, report_format)
                end

                ws.set_row(row, nil, nil, 1, 1)
                row = row + 1

              end

            end

            row_num_adjuster = 0


            if end_date.end_of_month.eql?(end_date) and tiered_amount #2nd half of Month or a full Month
              if tiered_amount and total_funded_for_period_and_branch > tiered_amount
                ws.write(row, 0, 'Tier Adjustment', format_def)

                ws.write(row, 5, lo.name_last_first)
                ws.write(row, 6, "=G#{row}")
                ws.write(row, 7, "=H#{row}")

                ws.write(row, 8, calc_percent(lo_loan_compensation.tiered_split_adjustment), (cols[8][:cell_format] || format_def))
                ws.write(row, 9, "=(I#{row+1}*#{total_funded_for_period_and_branch})", (cols[9][:cell_format] || format_def))

                ws.set_row(row, nil, nil, 1, 1)
                row = row + 1
                row_num_adjuster = 1
              end
            end

            #row - 0 based index of the current row 
            #row + 1 - actual line number

            ws.set_row(row, nil, nil, 0, 0, 1)        # Collapsed flag.

            top_row_in_group = row + 1 - loans.count - row_num_adjuster
            bottom_row_in_group = row

            ws.write(row, 2, "=SUBTOTAL(9,C#{top_row_in_group}:C#{bottom_row_in_group})", format_curr_tot)
            ws.write(row, 4, get_ulti_pro(lo, branch), format_num)
            ws.write(row, 5, "#{lo.name_last_first} Total", format_bold)
            ws.write(row, 6, branch.branch_name, format_bold)
            ws.write(row, 7, branch.institution_number, format_bold)
            ws.write(row, 9, "=SUBTOTAL(9,J#{top_row_in_group}:J#{bottom_row_in_group})", format_curr_tot)
            ws.write(row, 11, "=IF(J#{row + 1}+K#{row + 1}>0,J#{row + 1}+K#{row + 1},0)", format_curr_tot)
            ws.write(row, 12, "Inactive since #{lo.terminated_at.strftime('%m/%d/%Y') if lo.terminated_at}", format_err) unless lo.is_active

          end

        end
      end

    end
      
    grand_total_row = row + 4
    ws.write(grand_total_row, 2, "=SUBTOTAL(9,C2:C#{grand_total_row})", format_curr_tot)
    ws.write(grand_total_row, 5, "Grand Total", format_bold)
    ws.write(grand_total_row, 9, "=SUBTOTAL(9,J2:J#{grand_total_row})", format_curr_tot)
    ws.write(grand_total_row, 11, "=SUBTOTAL(9,L2:L#{grand_total_row})", format_curr_tot)

    # ws.set_row(grand_total_row, nil, nil, 0, 0, 1)        # Collapsed flag.

    workbook.close

    save_attachment(path, true)
    
  end

private

  def calc_percent(val)
    val / 100 if val    
  end  

  def calc_commission(loan, lo_loan_compensation, comm_percent, lo)

    # Just in case we are getting improper data.
    return 0 if lo_loan_compensation.blank? # Changed per CTMWEB-533
    # Now check to see if we are a branch manager that doesn't get a commission.
    return 0 if lo.current_profile_for_branch(loan.branch.id).try(:title).eql?('Branch Manager / NON Storefront')

    # Everything else.
    min_comm = lo_loan_compensation.try(:lo_min) || DEFAULT_GROSS_COMMISSION

    return min_comm unless comm_percent
    raw_comm = loan.original_balance * comm_percent
     
    if raw_comm < min_comm
      min_comm
    elsif lo_loan_compensation.lo_max and raw_comm > lo_loan_compensation.lo_max
      lo_loan_compensation.lo_max
    else
      raw_comm
    end
  end

  def borrower_name(loan)
    borrower = loan.borrowers.where(borrower_id: 'BRW1')[0]
    "#{borrower.last_name}, #{borrower.first_name}" if borrower
  end

  def get_ulti_pro(lo, branch)
    ultipro_id = lo.current_profile_for_branch(branch.id).try(:ultipro_emp_id)
    unless ultipro_id.present?
      profile_with_ultipro = DatamartUserProfile.where{ (datamart_user_id == lo.id) & (ultipro_emp_id.not_eq nil) }.last
      ultipro_id = profile_with_ultipro.ultipro_emp_id if profile_with_ultipro.present?
    end
    ultipro_id
  end
end
