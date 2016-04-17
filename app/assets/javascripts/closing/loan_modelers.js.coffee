# calculations for dodd-frank modeler
doDoddFrankCalc = (frmId) ->

  $('#' + frmId).each ->
    closingCost = addTheNumbers($(this).find('.num'))
    closingCredit = addTheNumbers($(this).find('.df-minus'))

    resultVal = $('#premium_pricing').val() - closingCost + closingCredit

    valid = (resultVal <= 0)
    $(this).find(".alert")
      .toggleClass('alert-success', valid)
      .toggleClass('alert-error', !valid)
    $(this).find("#difference,#message")
      .toggleClass('green', valid)
      .toggleClass('red', !valid)

    message = if valid then "Success" else "Fail"
    $(this).find("#message").val(message)

    $(this).find("#difference").val(resultVal).formatCurrency()
    $(this).find("#closing_cost").val(closingCost).formatCurrency()

    loanType = $('#loan_type').val()
    wholeSaleMessage = "This is a WholeSale Loan, remove the value from the Wire if applicable."

    if loanType == "W0-Wholesale Standard"
      $(this).find("#orig_message").val(wholeSaleMessage)
    else
      $(this).find("#orig_message").val('')

addTheNumbers = (numberFields) ->
  sum = 0.0
  $(numberFields).each ->
    val = $(this).val().replace(',','')
    sum += parseFloat(val) if !isNaN(val) and val.length > 0
  return sum


doFundingCalc = (fundId) ->

  $('#' + fundId).each ->
    fundAdd = addTheNumbers($(this).find('.fund_add'))
    fundSubtract = addTheNumbers($(this).find('.fund_minus'))
    

    wireTotal = fundAdd - fundSubtract
    losWire = $('#los_wire').val()
    fundResultVal = parseFloat(losWire) - parseFloat(wireTotal)

    loanType = $('#loan_type').val()
    wholeSaleMessage = "This is a WholeSale Loan, remove the value from the Wire if applicable."

    if loanType == "W0-Wholesale Standard"
      $(this).find("#credit_message").val(wholeSaleMessage)
      $(this).find("#appr_message").val(wholeSaleMessage)
      $(this).find("#orig_message").val(wholeSaleMessage)
    else
      $(this).find("#credit_message").val('')
      $(this).find("#appr_message").val('')
      $(this).find("#orig_message").val('')

    $(this).find("#wire_amt").val(wireTotal).formatCurrency()
    $(this).find("#los_wire_formatted").val(losWire).formatCurrency()
    $(this).find("#diff").val(fundResultVal).formatCurrency()

# calculations for freddie relief loan modeler
doFreddCalc = (freddId) ->
  
  # pay off amount including accrued interest
  $('#' + freddId).each ->
    payoffAmount = addTheNumbers($(this).find('.add'))
      
    
    # unpaid balance multiplied by 4%
    upbAmount = $('#upb').val() * 0.04

    if  $('#trid_loan').val() == 'true'
      # results of step three dependent on value of upb percent and closing cost (must be below 5k)
      resultsStepThree = 0.0
      closing_cost = $('#fredd_closing_cost').val()
      if (closing_cost < 5000)
        resultsStepThree = $('#fredd_closing_cost').val()
      else
        resultsStepThree = 5000
    else
      #unpaid balance cannot exceed $5k
      if upbAmount > 5000
        $(this).find("#upb_perc").val(upbAmount).formatCurrency()
        $(this).find("#upb_perc_fail").val('UPB Percent Cannot Exceed $5,000.00')
        $("#upb_perc").addClass('red')
        $("#upb_perc_fail").addClass('red')
      else
        $(this).find("#upb_perc").val(upbAmount).formatCurrency()
        $(this).find("#upb_perc_fail").val('')
        $("#upb_perc").removeClass('red')

      # results of step three dependent on value of upb percent and closing cost (must be below 5k)
      resultsStepThree = 0.0
      closing_cost = $('#fredd_closing_cost').val()
      if (closing_cost <= upbAmount) and (closing_cost < 5000)
        resultsStepThree = $('#fredd_closing_cost').val()
      else if (closing_cost >= upbAmount) and (upbAmount < 5000)
        resultsStepThree = upbAmount
      else
        resultsStepThree = 5000

      $(this).find("#upb_perc").val(upbAmount).formatCurrency()

    # maximum loan amount
    maxLoanAmount = 0.0
    maxLoanAmount = parseFloat(resultsStepThree) + parseFloat(payoffAmount)

    # actual loan amount
    actualLoanAmount = $('#actual_loan_amount').val()
    # actual loan amount multplied by 2%
    actualLoanAountPerc = actualLoanAmount * 0.02
    # principal curtailment cannot exceed 1500 or 2% of actual loan amount
    if $('#princ_curt').val() > 1500 or $('#princ_curt').val() > actualLoanAountPerc
      $(this).find("#princ_curt").val()
      $(this).find("#princ_curt_fail").val('Cannot Exceed $1,500.00 or 2% of Loan Amount')
      $("#princ_curt").addClass('red')
      $("#princ_curt_fail").addClass('red')
    else
      $(this).find("#princ_curt").val()
      $(this).find("#princ_curt_fail").val('')
      $("#princ_curt").removeClass('red')

    # loan amount difference must be greater than zero for modeler to pass
    loanAmountDiff = maxLoanAmount - actualLoanAmount
    if loanAmountDiff > 0
      $(this).find("#max_actual_amount").val(loanAmountDiff).formatCurrency()
      $(this).find("#modeler_pass_or_fail").val('Success')
      $("#max_actual_amount").addClass('green').removeClass('red')
      $("#modeler_pass_or_fail").addClass('green').removeClass('red')
    else
      $(this).find("#max_actual_amount").val(loanAmountDiff).formatCurrency()
      $(this).find("#modeler_pass_or_fail").val('Fail')
      $("#max_actual_amount").addClass('red').removeClass('green')
      $("#modeler_pass_or_fail").addClass('red').removeClass('green')

    # actual loan amount minus principa curtailment cannot exceed maximum loan amount
    princCurt = $('#princ_curt').val()
    loanAmountPrincipal = actualLoanAmount - princCurt
    if loanAmountPrincipal > maxLoanAmount
      $(this).find("#actual_amount_princ_fail").val('Cannot Exceed Maximum Loan Amount')
      $("#actual_amount_princ_fail").addClass('red')
    else
      $(this).find("#actual_amount_princ_fail").val('')

    # cash to borrower cannot exceed $250
    cashToBorrower = $('#cash_to_borrower').val()
    if cashToBorrower > 250
      $(this).find("#cash_to_borrower_fail").val('Cannot Exceed $250')
      $("#cash_to_borrower_fail").addClass('red')
    else
      $(this).find("#cash_to_borrower_fail").val('')

    # sets values for inputs
    $(this).find("#payoff_amount").val(payoffAmount).formatCurrency()
    
    $(this).find("#upb_perc").val(upbAmount).formatCurrency()
    
    $(this).find("#step_three").val(resultsStepThree).formatCurrency()
    
    $(this).find("#max_loan_amount").val(maxLoanAmount).formatCurrency()

    $(this).find("#max_actual_amount").val(loanAmountDiff).formatCurrency()
   
    $(this).find("#actual_amount_princ").val(loanAmountPrincipal).formatCurrency()


doBrokerCompValidation = (brkrId) ->

  $('#' + brkrId).each ->
    maxBrokerComp = $('#max_broker_comp').val()
    totalBrokerComp = $('#total_gfe_broker_comp').val()

    valid = (parseFloat(totalBrokerComp) <= parseFloat(maxBrokerComp)) || (totalBrokerComp == "")
    
    $(this).find(".alert")
      .toggleClass('alert-success', valid)
      .toggleClass('alert-error', !valid)
    $(this).find("#pass_fail_msg")
      .toggleClass('green', valid)
      .toggleClass('red', !valid)

    message = if valid then "Success" else "Fail"
    $(this).find("#pass_fail_msg").val(message)
    old_href = $('#broker_comp_pdf').attr('href')
    new_href = old_href.replace(/total_comp=.*/, "total_comp=" + totalBrokerComp + "&message=" + message)
    $('#broker_comp_pdf').attr('href', new_href)



# allow for only number keys to be recognized in input
goodKey = (event, txtBox) ->
  # // Backspace, tab, enter, end, home, left, right
  # // We don't support the del key in Opera because del == . == 46.
  controlKeys = [8, 9, 13, 35, 36, 37, 39]
  # // IE doesn't support indexOf
  isControlKey = controlKeys.join(",").match(new RegExp(event.which))

  if (!event.which or #// Control keys in most browsers. e.g. Firefox tab is 0
      (97 <= event.which and event.which <= 105) or # // Always 1 through 9
      (49 <= event.which and event.which <= 57) or # // Always 1 through 9
      ((48 == event.which or 96 == event.which) and txtBox.val()) or # // No 0 first digit
      isControlKey) 
    # // Opera assigns values for control keys.
    true
  else
    false

# do calculations on key up for dodd-frank and funding modeler
$(document).ready ->
  $('.dodd_frank_calc').each ->
    frm_id = this.id
    $(this).on 'keyup', ".num, .df-minus, #premium_pricing", (event) ->
      if (goodKey(event, $(this)))
        doDoddFrankCalc(frm_id)

  # do calculations on key up for freddie relief modeler
  $('.fredd_calc').each ->
    fredd_id = this.id
    $(this).find(".add, .frd_calc").keyup (event) ->
      if (goodKey(event, $(this)))
        doFreddCalc(fredd_id)

  # do calculations on key up for funding modeler
  $('.fund_calc').each ->
    fund_id = this.id
    $(this).find(".fund_add, .fund_minus").keyup (event) ->
      if (goodKey(event, $(this)))
        doFundingCalc(fund_id)

  $('.broker_validate').each ->
    brkr_id = this.id
    $(this).find(".brkr_valid").keyup (event) ->
      if (goodKey(event, $(this)))
        doBrokerCompValidation(brkr_id)
  
  # submit form if form is validated
  $("form.modeler_validate").each ->
    $(this).submit ->
      if $(this).valid()
        $(".fields-invalid").hide()
        message = "Modeler submitted successfully."
        $(".fields-valid").removeClass("alert alert-error").addClass("alert alert-success").html message
        $(".fields-valid").show()
        setTimeout (->
          $(".fields-valid").fadeOut()
        ), 1000

  # disable pdf download if link is disabled
  $("#fd_pdf, #fund_pdf, #fredd_pdf").click (e) ->
    e.preventDefault() if $(this).hasClass("disabled")
  # submit form unless link is disabled
  $("#fd_submit, #fund_submit, #fredd_submit, #broker_submit" ).click ->
    $('.modeler_validate').find('.modeler_toggle_lock').val('')
    
    $(this).closest("form").submit() unless $(this).hasClass("disabled")
    
    $(".fields-invalid").hide()
    
    message = "Modeler saved successfully."
    
    $(".fields-valid").removeClass("alert alert-error").addClass("alert alert-success").html message unless $(this).hasClass("disabled")
    
    $(".fields-valid").show() unless $(this).hasClass("disabled")
    
    setTimeout (->
      $(".fields-valid").fadeOut()
    ), 5000
  
  template = '<div class="misc-fee"> <div class="control-group"> <div class="controls"> <input class="text_field num input-small editable" id="amount" name="misc_other_fees[][amount]" placeholder="Fee Amount" type="text"> <input class="text_field input-large editable" id="description" name="misc_other_fees[][description]" placeholder="Enter Fee Name" type="text"> <a class="btn btn-mini btn-danger remove-misc-other-fee">Del</a> </div> </div> </div>'

  $('.add_misc_fee').on 'click', (event) ->
    event.preventDefault()
    $('.misc_fees').append template

  $(document).on 'click', '.remove-misc-other-fee', (event) ->
    event.preventDefault()
    if confirm("Are you sure?") is true
      fee = $(this).closest('.misc-fee')
      id = fee.find('.id-field')
      if id.length > 0
        $.post this.href, ->
          $(fee).remove()
          $('.dodd_frank_calc').each ->
            doDoddFrankCalc(this.id)
      else
        $(fee).remove()
        $('.dodd_frank_calc').each ->
          doDoddFrankCalc(this.id)


  # loan modeler lock/unlock
  $(".modeler_validate").each ->
    frm = $(this)
    $(".modeler_toggle_class", frm).click ->
      if frm.valid()
        $('.remove-misc-other-fee, .add_misc_fee').toggle() if frm.attr('id') == 'dodd_frank'
        frm.find("span", this).toggle()
        $('.modeler_toggle_lock', frm).val('true')
        $this = $('.editable', frm)
        if $this.attr('readonly') 
          $this.removeAttr 'readonly'
          $('.modeler_pdf_submit', frm).toggleClass('disabled')
          $('.modeler_frm_submit', frm).toggleClass('disabled')
        else 
          $this.attr 'readonly', 'readonly'
          $('.modeler_pdf_submit', frm).toggleClass('disabled')
          $('.modeler_frm_submit', frm).toggleClass('disabled')
        $(this).closest('form').submit()
        $('.modeler_toggle_lock', frm).val('')

    if $('.modeler_lock', frm).val() == 'true'
      $('.editable', frm).attr 'readonly', 'readonly'
      $(".modeler_toggle_class span", frm).toggle()
      $('.modeler_pdf_submit', frm).toggleClass('disabled')
      $('.modeler_frm_submit', frm).toggleClass('disabled')
      $('.remove-misc-other-fee, .add_misc_fee').toggle() if frm.attr('id') == 'dodd_frank'

  # validate signup form on keyup and submit
  $(".modeler_validate").each ->
    $(this).validate(
  
      rules:
        premium_pricing: "required"
        admin_fee: "required"
        origination: "required"
        third_pt_proc_fee: "required"
        hoi_premium: "required"
        taxes_due: "required"
        misc_other_fees: "required"
        prorated_taxes: "required"
        loan_amount: "required"
        ny_mtg_tax: "required"
        lender_credit: "required"
        premium_price: "required"
        broker_comp_lndr_pd: "required"
        credit_to_cure: "required"
        mip_refund: "required"
        ctm_admin_whls: "required"
        credit_report: "required"
        appraisal_credit: "required"
        va_fund_fee: "required"
        escrow_holdback: "required"
        principal_reduction: "required"
        upb: "required"
        accrued_interest: "required"
        fredd_closing_cost: "required"
        actual_loan_amount: "required"
        princ_curt: "required"
        cash_to_borrower: "required"

      messages:
        premium_pricing: "Required Field"
        admin_fee: "Required Field"
        origination: "Required Field"        
        third_pt_proc_fee: "Required Field"
        hoi_premium: "Required Field"
        taxes_due: "Required Field"
        misc_other_fees: "Required Field"
        prorated_taxes: "Required Field"
        loan_amount: "Required Field"
        ny_mtg_tax: "Required Field"
        lender_credit: "Required Field"
        premium_price: "Required Field"
        broker_comp_lndr_pd: "Required Field"
        credit_to_cure: "Required Field"
        mip_refund: "Required Field"
        ctm_admin_whls: "Required Field"
        credit_report: "Required Field"
        appraisal_credit: "Required Field"
        va_fund_fee: "Required Field"
        escrow_holdback: "Required Field"
        principal_reduction: "Required Field"
        upb: "Required Field"
        accrued_interest: "Required Field"
        fredd_closing_cost: "Required Field"
        actual_loan_amount: "Required Field"
        princ_curt: "Required Field"
        cash_to_borrower: "Required Field"

      highlight: (label) ->
        $(label).closest(".control-group").addClass "error"

      success: (label) ->
        label.text("OK!").addClass("valid").closest(".control-group").addClass "success"

      onsubmit: false
      
      invalidHandler: (valEvent, validator) ->
          #valEvent is a jQuery Event object, so form is valEvent.target
          errorCount = validator.numberOfInvalids()
          if errorCount > 0
            errorList = validator.errorList
            summary = (if errorCount is 1 then "You missed 1 field. It has been highlighted" else "You missed " + errorCount + " fields. They have been highlighted")
            $(valEvent.target).find(".fields-invalid")
              .addClass("alert alert-error")
              .html(summary).show()
            setTimeout (->
              $(valEvent).find(".fields-invalid").fadeOut()
            ), 15000
          validator.focusInvalid()
    )  


  $(".dodd_frank_calc").each ->
    doDoddFrankCalc(this.id)
  
  $(".fredd_calc").each ->
    doFreddCalc(this.id)

  $(".fund_calc").each ->
    doFundingCalc(this.id)

  $(".broker_validate").each ->
    doBrokerCompValidation(this.id)

