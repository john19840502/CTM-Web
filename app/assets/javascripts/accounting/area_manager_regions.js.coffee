$(document).ready ->
  $(document).on "as:action_success", "#as_accounting__area_manager_regions-new--link", (e, action_link) ->
    $("#as_accounting__area_manager_regions-create--form").find("INPUT[name='commit']").val('Save Assignment')
