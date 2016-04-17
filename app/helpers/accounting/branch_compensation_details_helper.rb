module Accounting::BranchCompensationDetailsHelper

#   def effective_date_column(record)
#     I18n.localize(record.effective_date, :format => :pretty) rescue nil
#   end

#   def lo_traditional_split_column(record)
#     #number_to_percentage(record.lo_traditional_split * 100, precision: 2) rescue nil
#     number_to_percentage(record.lo_traditional_split, precision: 2) rescue nil
#   end

#   def tiered_split_low_column(record)
# #    number_to_percentage(record.tiered_split_low * 100, precision: 2) rescue nil
#     number_to_percentage(record.tiered_split_low, precision: 2) rescue nil
#   end

#   def tiered_split_high_column(record)
# #    number_to_percentage(record.tiered_split_high * 100, precision: 2) rescue nil
#     number_to_percentage(record.tiered_split_high, precision: 2) rescue nil
#   end

#   def tiered_amount_column(record)
#     number_to_currency(record.tiered_amount, precision: 0) rescue nil
#   end

#   def lo_min_column(record)
#     number_to_currency(record.lo_min, precision: 0) rescue nil
#   end

#   def lo_max_column(record)
#     number_to_currency(record.lo_max, precision: 0) rescue nil
#   end

#   def branch_compensation_detail_effective_date_form_column(record, options)
#     text_field :record, :effective_date, value: (I18n.localize(record.effective_date) rescue nil), class: 'date'
#   end

#   def branch_compensation_detail_lo_traditional_split_form_column(record, options)
# #    text_field :record, :lo_traditional_split, value: (number_with_precision(record.lo_traditional_split * 100, precision: 2) rescue nil)
#     text_field :record, :lo_traditional_split, value: (number_with_precision(record.lo_traditional_split, precision: 2) rescue nil)
#   end

#   def branch_compensation_detail_tiered_split_low_form_column(record, options)
# #    text_field :record, :tiered_split_low, value: (number_with_precision(record.tiered_split_low * 100, precision: 2) rescue nil)
#     text_field :record, :tiered_split_low, value: (number_with_precision(record.tiered_split_low, precision: 2) rescue nil)
#   end

#   def branch_compensation_detail_tiered_split_high_form_column(record, options)
# #    text_field :record, :tiered_split_high, value: (number_with_precision(record.tiered_split_high * 100, precision: 2) rescue nil)
#     text_field :record, :tiered_split_high, value: (number_with_precision(record.tiered_split_high, precision: 2) rescue nil)
#   end

#   def branch_compensation_detail_tiered_amount_form_column(record, options)
#     text_field :record, :tiered_amount, value: (number_with_precision(record.tiered_amount, precision: 0) rescue nil)
#   end

#   def branch_compensation_detail_lo_min_form_column(record, options)
#     text_field :record, :lo_min, value: (number_with_precision(record.lo_min, precision: 0) rescue nil)
#   end

#   def branch_compensation_detail_lo_max_form_column(record, options)
#     text_field :record, :lo_max, value: (number_with_precision(record.lo_max, precision: 0) rescue nil)
#   end

end
