class Compliance::Hmda::HmdaTransformations
  def initialize(row, period)
    @loan = row.loan_general
    @row = row
    @period = period
  end

  def do_transformations
    if @period.eql?('m')
      self.translate_race_fields
      self.translate_preapproval_actions
      self.income_flag_fields
      self.action_code_transformations

      if @loan
        self.preapproval_transformations
        self.set_purchaser_type
      end
      @row.save_changed_values
      @row.transformed = true

    else #for annual and quarterly reports we only do purchaser type transformations

      self.set_purchaser_type if @loan
      
    end
    
    @row.save!
  end

  def translate_race_fields
    apraces = [@row.aprace, @row.aprace1, @row.aprace2, @row.aprace3, @row.aprace4, @row.aprace5].compact.join(',').split(',').map(&:to_i)
    
    if apraces.count > 5
      raise "For loan # #{aplnno}, APRACE fields contain more than 5 elements combined"
    else
      apraces.each_with_index{|v, i| @row["aprace#{i + 1}".to_sym] = v}
    end

    capraces = [@row.caprace, @row.caprace1, @row.caprace2, @row.caprace3, @row.caprace4, @row.caprace5].compact.join(',').split(',').map(&:to_i)
    if capraces.count > 5
      raise "For loan # #{aplnno}, CAPRACE fields contain more than 5 elements combined"
    else
      capraces.each_with_index{|v, i| @row["caprace#{i + 1}".to_sym] = v} if @row.caprace
    end
  end

  def translate_preapproval_actions
    return unless @row.preappr == 1 && (@row.propstreet =~ /TBD/ || @row.propcity =~ /TBD/ || @row.propstate =~ /TBD/ )
    @row.action_code = 8 if @row.action_code == 2
    @row.action_code = 7 if @row.action_code == 3
  end

  def income_flag_fields
    @row.tincome = 'NA' if (@row.loan_prog and @row.loan_prog.include?('IRRL')) or @row.employee_loan
    @row.tincome = 'NA' if (@row.loan_prog and @row.loan_prog.include?('Streamline') and (@row.tincome.blank?))
  end

  def action_code_transformations
    if (2..8).include?(@row.action_code)
      @row.lockdate = nil
      @row.apr = "NA"
      @row.spread = "NA"
    end
  end

  def preapproval_transformations
    if @row.actdate >= TRID_DATE 
      @row.preappr = 3
    else
      if @loan.is_preapproval?
        @row.preappr = 1
      elsif self.preapproval_not_applicable?
        @row.preappr = 3
      else
        @row.preappr = 2
      end
    end
  end

  def preapproval_not_applicable?
    @loan.channel == Channel.reimbursement.identifier ||
      @loan.is_refi? ||
      @row.actdate <= MAY_7_2012
  end

  MAY_7_2012 = Date.new(2012, 5, 7)

  def set_purchaser_type
    if @loan.investor_lock.investor_lock_expires_on.present? && (@loan.investor_lock.investor_lock_expires_on < Date.today) &&
      (2..8).include?(@row.action_code) == false
      @row.purchtype = choose_purchaser_type(@loan.investor_lock.investor_name, @row.purchtype)
    else
      @row.purchtype = '0'
    end
    # Save the investor name.  We *can* get this from loan later, but it turns out 
    # there's no performant way to do this using datatables.  Either search breaks,
    # or paging breaks, or it is very slow (more than 10 sec) to load anything.  If
    # we just store the investor name in the loan compliance events model, it works
    # and it's fast.  So, eh.  
    @row.investor_name = @loan.investor_lock.investor_name
  end

  def choose_purchaser_type investor, prior_type
    return '0' if investor.blank?
    HmdaInvestorCode::investor_codes.each do |code, names|
      return code if names.include?(investor)
    end
    prior_type
  end

end
