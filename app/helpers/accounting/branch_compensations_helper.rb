module Accounting::BranchCompensationsHelper

#   def institution_id_column(record)
#     "CTM #{record.branch.city} - #{record.institution_id}" rescue nil
#   end

#   def branch_form_column(record, options)
#     record.branch.branch_name
#   end

#   def current_effective_date_column(record)
#     I18n.localize(record.current_package.effective_date, :format => :pretty) rescue nil
#   end

#   def current_lo_traditional_split_column(record)
# #    number_to_percentage(record.current_package.lo_traditional_split * 100, precision: 2) rescue nil
#     number_to_percentage(record.current_package.lo_traditional_split, precision: 2) rescue nil
#   end

#   def current_tiered_split_low_column(record)
# #    number_to_percentage(record.current_package.tiered_split_low * 100, precision: 2) rescue nil
#     number_to_percentage(record.current_package.tiered_split_low, precision: 2) rescue nil
#   end

#   def current_tiered_split_high_column(record)
# #    number_to_percentage(record.current_package.tiered_split_high * 100, precision: 2) rescue nil
#     number_to_percentage(record.current_package.tiered_split_high, precision: 2) rescue nil
#   end

#   def current_tiered_amount_column(record)
#     number_to_currency(record.current_package.tiered_amount, precision: 0) rescue nil
#   end

#  def options_for_association_conditions(association)
#    if !association.name.eql?(:branch_compensation_details) and
#      !association.name.eql?(:datamart_user_compensation_plans)
#      ['roles.id != ?', association]
#    else
#      super
#    end
#  end

end
