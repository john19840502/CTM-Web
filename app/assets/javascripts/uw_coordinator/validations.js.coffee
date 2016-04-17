main_params = ->
  return add_param('signature_1003_date') +
    add_param('most_recent_imaged_gfe_date') +
    add_param('initial_imaged_ctm_gfe_date') +
    add_param('til_signature_date_from_image')

add_param = (param) ->
  "&" + param + "=" + $('#' + param + '').val()

calc_delta_api = ->
  if $('#prior_apr').val() is '' or ($('#prior_apr').val() * 1) == 0 or ($('#prior_apr').val() * 1).toString() == 'NaN'
    $('#apr_increase_decrease').text('')
  else
    _delta = $('#current_apr').text() - $('#prior_apr').val()
    $('#apr_increase_decrease').text((_delta * 1).toFixed(3))

check_rest_of_dates = ->
  $.each ['#most_recent_imaged_gfe_date','#initial_imaged_ctm_gfe_date','#til_signature_date_from_image'], (index, value) ->
    check_input value

check_input = (_id) ->
  if $(_id).val() is ''
    $(_id).closest('.control-group').addClass 'error'

clean_up_input_errors = ->
  $.each ['#signature_1003_date','#most_recent_imaged_gfe_date','#initial_imaged_ctm_gfe_date','#til_signature_date_from_image','#prior_apr'], (index, value) ->
    clean_up_input_error value

clean_up_input_error = (_id) ->
  $(_id).closest('.control-group').removeClass 'error'

message_display = (msg, lvl) ->
  return  '<div class="alert alert-' + lvl + '">' +
          ' <span class="alert-heading" style="font-weight: bold; font-size: 14px;line-height: 18px;">' +
          msg + 
          ' </span>' + 
          (if lvl is 'error' then ' <br>Please enter desired dates into every date field before submitting validation request.' else '') + 
          '</div>'

App.uwc_validations = uwc_validations = (loan_num) ->
  clean_up_input_errors()
  check_input '#signature_1003_date'

  $('#validation_header').fadeIn 'slow'

  if $('.control-group.error').length > 0
    $('#validation_messages').hide().html(message_display('Validations could not be performed.', 'error')).fadeIn()
    return false

  $('#validation_messages').hide().html(message_display('Loading validations...', 'warning')).fadeIn()
  $.get('/pre-closing/uw_coordinator/validations/process_registration_validations?id=' + loan_num + add_param('signature_1003_date'), (data) -> 
    $('#validation_messages').hide().html(data).fadeIn 'slow'
  )

App.uwc_compliance = uwc_compliance = (loan_num) ->
  clean_up_input_errors()
  check_input '#signature_1003_date'
  check_rest_of_dates()

  $('#compliance_header').fadeIn 'slow'

  if $('.control-group.error').length > 0
    $('#compliance_messages').hide().html(message_display('Compliance validation could not be performed.', 'error')).fadeIn()
    return false

  $('#compliance_messages').hide().html(message_display('Loading compliance validations...', 'warning')).fadeIn()
  $.get('/pre-closing/uw_coordinator/validations/process_registration_compliance_validations?id=' + loan_num + main_params() + add_param('prior_apr'), (data) -> 
    $('#compliance_messages').hide().html(data).fadeIn 'slow'
  )

uwc_save = (loan_num) ->
  clean_up_input_errors()
  check_input '#signature_1003_date'
  check_rest_of_dates()
  # check_input '#prior_apr'

  if $('.control-group.error').length > 0
    $('#save_message').hide().html(message_display('Data could not be saved.', 'error')).fadeIn()
    return false

  $('#save_message').hide().html(message_display('Saving data...', 'warning')).fadeIn()
  $.get('/pre-closing/uw_coordinator/validations/process_registration_validation_save?lid=' + loan_num + main_params() + add_param('prior_apr'), (data) -> 
    $('#save_message').hide().html(data).fadeIn 'slow'
    $("#reg_pdf").removeClass "disabled"
  )

uwc_pdf = (loan_num) ->
  clean_up_input_errors()
  check_input '#signature_1003_date'
  check_rest_of_dates()

  if $('.control-group.error').length > 0
    $('#save_message').hide().html(message_display('PDF document could not be generated.', 'error')).fadeIn()
    return false

App.process_registration_validation_alerts = process_registration_validation_alerts = (path_to_exec) ->
  $.get(path_to_exec, (data) ->)

$(document).ready ->
  $('#prior_apr').keyup (event) ->
    if App.goodKey(event, $(this))
      calc_delta_api()

  # disable pdf download if link is disabled
  $("#reg_pdf").click (e) ->
    e.preventDefault() if $(this).hasClass "disabled"
    uwc_pdf($('#loan_num').val()) unless $(this).hasClass "disabled"

  $("#reg_pdf").removeClass("disabled") if $('#signature_1003_date').val() != ''

  $("#reg_submit").click (e) ->
    e.preventDefault()
    uwc_save($('#loan_num').val()) unless $(this).hasClass "disabled"
