# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  $('a.assign-to-me').click (e) ->
    e.preventDefault()
    caller = $(this)
    url    = $(this).attr('href')
    $.ajax(
      url: url,
      type: 'POST',
      success: (data, status, xhr) -> 
        $(caller).parent().html(data)
      error: (xhr, status, error) ->
        alert(xhr.responseText)
    )