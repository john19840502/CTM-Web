$(document).ready ->


  #current_date = $.datepicker.formatDate('mm/dd/yy ', new Date())
  current_date = ->
    d     = new Date()
    month = d.getMonth() + 1
    day   = d.getDate()
    year  = d.getFullYear()
    hour  = d.getHours()
    min   = d.getMinutes()
    sec   = d.getSeconds()
    cur_value = month + '/' + day + '/' + year + ' ' + hour + ':' + min + ':' + sec

  $('abbr.timeago').attr('title', current_date()).html(current_date())
  $('abbr.timeago').timeago()

  $(document).on 'click', '.print-page', (event) ->
    event.preventDefault()
    window.print()

  #  * ==========================================================
  #  * Attach bootstrap menu dropdown behavior to the top navigation
  #  * ==========================================================
  $("#navigation ul").first().addClass "nav"
  App.prepare_dropdown_layouts($("ul.nav"), false)

  $("li.submenu").hover (->
    $(this).children("ul").removeClass("submenu-hide").addClass "submenu-show"
  ), ->
    $(this).children("ul").removeClass(".submenu-show").addClass "submenu-hide"

  #  * ==========================================================
  #  * Attach bootstrap tab behavior to the tabbed navigation
  #  * ==========================================================
  $("#navigation_tabs ul").first().addClass "nav nav-tabs"
  App.prepare_dropdown_layouts($("ul.nav-tabs"), false)

  #  * Remove the active class from sublist items - the styles don't accomodate it */
  $("ul.nav-tabs ul.dropdown-menu li.active").removeClass "active"

  #  * Adds datatable functionality to tables with .datatable class
  $(".datatable").dataTable
    aaSorting: []
    bPaginate: false
    bProcessing: true
    bSortClasses: false
    oLanguage:
      sSearch: "<i class='icon-search'></i> Search:"

  #  * Adds datatable functionality to tables with .datatable class
  $(".server_side_datatable").dataTable
    aaSorting: []
    bPaginate: true
    sPaginationType: "full_numbers"
    bProcessing: true
    bServerSide: true
    bSortClasses: false
    sServerMethod: "POST"
    sAjaxSource: $('.server_side_datatable').data('source')
    oLanguage:
      sSearch: "<i class='icon-search'></i> Search:"

  $ "navigation_breadcrumbs"
  $(".alert-message").alert()
  $(".as_form .submit").addClass "btn btn-success"
  $(".as_cancel").addClass "btn"
  $(".accordion").accordion()

  $("div.modal-backdrop").click ->
    $(".modal-body-content").html ""
    $(".throbber").show()

  $(".datepicker, .datetime_picker").datepicker
    dateFormat: 'mm/dd/yy'
    altFormat: 'yy-mm-dd'


  # Monitor the click event for the date field and then setup
  # the datepicker.

  $(document).on 'click', '.as_form .date', (event) ->
    picker_options = {
      showOn: 'focus',
      dateFormat: 'mm/dd/yy',
      altFormat: 'yy-mm-dd'
    }
    $(this).datepicker(picker_options).focus()

  # Refresh last transaction date
  last_transaction = ->
    $.get('/last-trans', (data) ->
      $('.last-transaction span.timestamp').html(data)
    )

  setInterval(last_transaction, 60000)
  # run it on load
  last_transaction()

  # For all those times when you want to edit something by double clicking on it and being taken to a modal window
  $(document).on 'dblclick', '.dblclick-edit', (event) ->
    $dialog = $('<div></div>')
    $dialog.load($(this).attr('edit_path')).dialog
      title: $(this).attr('edit_title') || "Note"
      width: 500
      height: 500

  # set up some basic client side validations for active scaffold forms.
  # To use this, at least one column in the form must have the class 'validate-required'.
  validate_the_form = ->
    theForm = $('.validate-required').closest('form')
    # active scaffold puts the required class on some parent element, but jquery.validate
    # expects it to be on the input element itself.
    theForm.find('.required input').addClass('required')
    theForm.validate()

  validate_the_form()

  $(document).on('as:action_success', 'a.as_action', (e, action_link) ->
    validate_the_form() if(action_link.adapter)
  )

  $('.best_in_place').best_in_place()

window.App = {}

App.prepare_dropdown_layouts = prepare_dropdown_layouts = (ul_element, is_submenu) ->
  ul_element.children('li').each ->
    #  * examining each LI element to see if it has a nested menu
    nested_ul_elements = $(this).children("ul")
    #  * If it has nested ULs
    if nested_ul_elements.length > 0
      #  * mark LI that contains it as a dropdown
      $(this).addClass "dropdown"
      #  * mark nested UL as dropdown-menu
      nested_ul_elements.addClass "dropdown-menu"

      #  * if it is not a top level menu
      if (is_submenu)
        #  * add some classes and stuff for submenu look and feel and functionality
        nested_ul_elements.addClass "submenu-hide"
        $(this).addClass "submenu"
        $(this).children("a").append "<span style='float:right;margin-left:10px;'>&raquo;</span><span style='clear:both'></span>"
      else
        #  * otherwise, mark it up as Twitter Bootstrap dropdown
        $(this).children("a").addClass("dropdown-toggle").attr("data-toggle", "dropdown").attr("href", "#menu1").append "<b class=\"caret\"></b>"

      #  * rinse, repeat... :)
      App.prepare_dropdown_layouts($(this).children("ul"), true)

# allow for only number keys to be recognized in input
App.goodKey = goodKey = (event, txtBox) ->
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


# tell underscore.js to use {{ and }} as code interpolation delimiters.  
# see http://underscorejs.org/#template
_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g

