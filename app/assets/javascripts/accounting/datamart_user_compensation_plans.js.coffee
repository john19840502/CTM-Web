$(document).ready ->
  $(document).on "as:action_success", "#as_accounting__datamart_user_compensation_plans-new--link", (e, action_link) ->
    $("#as_accounting__datamart_user_compensation_plans-create--form").find("INPUT[name='commit']").val('Save Plan')
