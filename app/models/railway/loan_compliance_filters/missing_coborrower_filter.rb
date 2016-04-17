class LoanComplianceFilters::MissingCoborrowerFilter < LoanComplianceFilter

  def filter_query period, type
  	null_changed_values_column

    # this is only necessary because of GROUP BY clase requires every column in SELECT to be mentioned in  GROUP BY
    # and we need aplnno to be the first one in GROUP BY, and id column has to be fully qualified

    cols = (['aplnno', "id"] + (LoanComplianceEvent.column_names - ['id', 'aplnno'])).join(', ')

    # LoanComplianceEvent.for_period(period, type).
    #   joins(:borrowers).
    #   group(cols).
    #   having("count(#{Borrower.table_name}.borrower_id) = 1").
    #   where { ((capeth.not_eq 5) | (caprace1.not_eq 8) | (capsex.not_eq 5)) & (reportable != false) }

    sql = <<-eos 
          WITH brw(loanGeneral_Id, loan_num)
          AS
          (select lg.loanGeneral_Id as lgid, lg.LenderRegistrationIdentifier from LENDER_LOAN_SERVICE.dbo.BORROWER br 
          inner join LENDER_LOAN_SERVICE.dbo.LOAN_GENERAL lg on lg.loanGeneral_Id = br.loanGeneral_Id
          group by lg.loanGeneral_Id, lg.LenderRegistrationIdentifier
          having (count(borrower_id) = 1))
          ,
          loans (#{cols})
          AS
          (select #{cols}
          from CTM.railway.ctmweb_loan_compliance_events_#{Rails.env}
          where ((capeth != 5) or (caprace1 != 8) or (capsex != 5)) and (reportable = 1))
          SELECT #{cols}
          FROM brw inner join loans on loans.aplnno = brw.loan_num
          #{"where #{period}" if period.present?}
      eos

      # ActiveRecord::Base.connection.select_all(sql)
      LoanComplianceEvent.find_by_sql(sql)
  end

  def filter_columns
    %w(apptakenby capeth caprace1 capsex last_updated_by)
  end

  def filter_title
    'HMDA Missing Co-borrower Filter'
  end

end