module Closing::LoanModelersHelper 
  # def loan_status_field(loan)
  #   if loan.is_locked?
  #     "Lock expires: #{loan.lock_expiration_at.in_time_zone('Eastern Time (US & Canada)').strftime('%m/%d/%Y')}"
  #   else
  #     "Not Locked"
  #   end
  # end

  # def link_to_add_misc_fee_fields(lbl, modeler)
  #   modeler.dodd_frank_modeler_misc_other_fees << DoddFrankModelerMiscOtherFee.new
  #   render('closing/loan_modelers/partials/dodd_frank_modeler_misc_other_fees', f: misc_fee, i: misc_fee.id)

  #   link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  # end

end