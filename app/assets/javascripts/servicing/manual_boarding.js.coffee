# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->

  $('a.finalize').click (e) ->
    all_loans = ''
    e.preventDefault()
    $('.loan_list tr td.loan_number').each (i, val) ->
      all_loans += $(val).html() + ','
    if $(this).attr('disabled') == 'disabled'
      alert('Please select loans to board.')
    else
      $.get '/servicing/manual_boarding/board', {loan_numbers: all_loans}, (res) ->
        alert(res)

  $(document).on 'click', '.add-loan-to-boarding', (e) ->
    e.preventDefault();
    loan_number = $(this).attr('href');
    string = '<tr><td class="loan_number">' + loan_number + '</td>'
    string += '<td><a href="' + loan_number + '" class = "btn btn-mini btn-danger remove-loan">Remove</a></td></tr>'
    $('tbody.loan_list').append(string);
    rowCount = $('.loan_list tr').length;
    if rowCount >= 1
      $('a.finalize').removeAttr('disabled');
    

  $(document).on 'click', '.remove-loan', (e) ->
    e.preventDefault()
    $(this).parent().parent().remove()
    rowCount = $('.loan_list tr').length;
    if rowCount == 0
      $('a.finalize').attr('disabled', 'disabled')