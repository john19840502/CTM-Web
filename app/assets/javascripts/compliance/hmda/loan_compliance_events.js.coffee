$ ->
  report_type = $('#report_type')
  $('#m_period').hide()
  $('#q_period').hide()

  if report_type.val() == 'q'
    $('#q_period').attr('disabled', false)
    $('#q_period').show()
    $('#m_period').hide()
    $('#m_period').attr('disabled', true)
    $('#avista_import').attr('disabled', true).attr('href', '#')
  else
    $('#m_period').attr('disabled', false)
    $('#m_period').show()
    $('#q_period').hide()
    $('#q_period').attr('disabled', true)
    $('#avista_import').attr('disabled', false)

  report_type.change ->
    if report_type.val() == 'q'
      $('#q_period').attr('disabled', false)
      $('#q_period').show()
      $('#m_period').hide()
      $('#m_period').attr('disabled', true)
    else
      $('#m_period').attr('disabled', false)
      $('#m_period').show()
      $('#q_period').hide()
      $('#q_period').attr('disabled', true)

  setTimeout ( ->
    window.table = $('.loan_compliance_events').dataTable()

    $(table).on "draw", ->
      callback = callback = drawTitles(table.fnGetNodes())

    callback = drawTitles(table.fnGetNodes())

  ), 1000


  $('#goToEdit').click ->
    loan_num = $('input#loan_num').val()
    if loan_num != "" && $.isNumeric(loan_num)
      window.location.href = '/compliance/hmda/loan_compliance_events/' + loan_num + '/edit'
    else
      alert 'Loan Number Required.'

  drawTitles = (rows) ->
    for row in rows
      loan_cell = $(row).find("td")[1]
      loan_num = $(loan_cell).text()
      $(row).find("td").each (index, cell) ->
        @setAttribute "title", "App #: " + loan_num + " :: " + $($('.loan_compliance_events').dataTable().find('tr')[0])[0].cells[index].innerText
        $(cell).tooltip()
        return

      $(loan_cell).html("<a href='/compliance/hmda/loan_compliance_events/" + loan_num +  "/edit' target='_blank'>" + loan_num + "</a>")
