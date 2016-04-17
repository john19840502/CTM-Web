module Accounting::DatamartUserCompensationPlansHelper

  def available_employees employees, bid
    employees.sort_by(&:last_name).map do |emp| 
      profile = emp.current_profile_for_branch(bid)
      emp_id = profile.try(:title).present? ? emp.id : -1
      [emp.name_last_first, emp_id]
    end
  end

  # def branch_compensation_form_column(record, options)
  #   html = '<table>'
  #   compensations = BranchCompensation.where(institution_id: record.datamart_user.datamart_user_profile.institution_id).all
  #   compensations.reject!(&:terminated?)
  #   compensations.collect {|p|
  #     eff_date = " [eff. date #{I18n.localize(p.current_or_future_package.effective_date, :format => :pretty)}]" if (p.current_package.nil? and p.current_or_future_package)
  #     [ "#{p.name}#{eff_date}", p.id ]
  #   }.each do |bc|
  #     html << "<tr><td style='width: 50px;'>#{radio_button(:record, :branch_compensation, bc[1])}</td><td style='width: 550px;'>#{bc[0]}</td></tr>"
  #   end
  #   html << "</table>"
  # end

  # def effective_date_form_column(record, options)
  #   text_field :record, :effective_date, value: (I18n.localize(record.effective_date) rescue nil), class: 'date'
  # end

  # def bsm_override_form_column(record, options)
  #   text_field :record, :bsm_override, value: (record.bsm_override rescue nil)
  # end

  # def per_loan_processed_form_column(record, options)
  #   text_field :record, :per_loan_processed, value: (number_with_precision(record.per_loan_processed, precision: 0) rescue nil)
  # end

  # def per_loan_branch_processed_form_column(record, options)
  #   text_field :record, :per_loan_branch_processed, value: (number_with_precision(record.per_loan_branch_processed, precision: 0) rescue nil)
  # end

  # def bsm_override_form_column(record, options)
  #   text_field :record, :bsm_override, value: (number_with_precision(record.bsm_override, precision: 0) rescue nil)
  # end

  # def effective_date_column(record)
  #   I18n.localize(record.effective_date, :format => :pretty) rescue nil
  # end

  # def lo_min_column(record)
  #   number_to_currency(record.branch_compensation.plan_package(record.created_at).lo_min, precision: 0) rescue nil
  # end

  # def lo_max_column(record)
  #   number_to_currency(record.branch_compensation.plan_package(record.created_at).lo_max, precision: 0) rescue nil
  # end

  # def per_loan_processed_column(record)
  #   number_to_currency(record.per_loan_processed, precision: 0) rescue nil
  # end

  # def per_loan_branch_processed_column(record)
  #   number_to_currency(record.per_loan_branch_processed, precision: 0) rescue nil
  # end

  # def bsm_override_column(record)
  #   number_to_percentage(record.bsm_override, precision: 2) rescue nil
  # end

  # def created_at_column(record)
  #   I18n.localize(record.created_at, :format => :pretty)
  # end 

  # def plan_lo_traditional_split_column(record)
  #   number_to_percentage(record.branch_compensation.plan_package(record.created_at).lo_traditional_split, precision: 2) rescue nil
  # end

  # def plan_tiered_split_low_column(record)
  #   number_to_percentage(record.branch_compensation.plan_package(record.created_at).tiered_split_low, precision: 2) rescue nil
  # end

  # def plan_tiered_split_high_column(record)
  #   number_to_percentage(record.branch_compensation.plan_package(record.created_at).tiered_split_high, precision: 2) rescue nil
  # end

  # def plan_tiered_amount_column(record)
  #   number_to_currency(record.branch_compensation.plan_package(record.created_at).tiered_amount, precision: 0) rescue nil
  # end
end
