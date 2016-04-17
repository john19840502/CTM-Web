window.InitialDisclosureWorkQueue = {
  initialize: (options={}) ->
    assignSortType = options.assignSortType || 'dom-text'

    work_queue = $("#work_queue_items").DataTable(
      "paging":   false
      "lengthMenu": [10, 20, 50]
      buttons: [
        {
          extend: 'excel'
          text: 'Save to XLS'
          className: 'btn btn-primary'
          exportOptions: {
            columns: '.exportable'
          }
        }
      ]
      orderCellsTop: true
      columnDefs: [
          width: '180px'
          orderDataType: "dom-select"
          targets: 1
        ,
          orderDataType: assignSortType
          targets: 3
      ]
      createdRow: (row, data, index) ->
        if data[7].match /missing/i
          $('td', row).eq(7).addClass('zomg')

      initComplete: ->
        this.api().columns().every ->
          column = this
          i = column.index()

          # this is super fragile but I can't figure out how else to get the thing I want
          header = $(column.context[0].aoHeader[1][i].cell)

          $(header).find('.select-filter').on 'change', ->
            val = $.fn.dataTable.util.escapeRegex(
              $(this).val()
            )
            column.search(val ? '^' + val + '$' : '', true, false).draw()

          $(header).find('.checkbox-filter').on 'change', ->
            val = $.fn.dataTable.util.escapeRegex(
              $(this).val()
            )

            column.search(val, true, false).draw()

          $(header).find('.text-filter').attr('placeholder', 'Type to filter').on 'keyup', ->
            v = $(this).val()
            column.search(v, true, false).draw()

          $(header).find('.populate-me').each ->
            select = $(this)
            select.append('<option value=""></option>')
            column.data().unique().sort().each((d,j) ->
              select.append('<option value="' + d + '">' + d + '</option>')
            )
    )

    work_queue.buttons().container().appendTo($('.span6:eq(0)', work_queue.table().container()))

    $('.spinner').hide()

    eventFired = ( type ) ->
      table = $('#work_queue_items').DataTable()
      order_arr = table.order()
      order_str = "Sorting order"
      order_str += (' ' + table.column(col[0]).header().innerHTML + ' ' + col[1] for col in order_arr)


      n = $('#order_info')[0]
      n.innerHTML = '<div>' + order_str + '</div>'

    $('#work_queue_items').on 'order.dt', (event) => 
      eventFired event

    post = (self, url, data) ->
      spinner = $(self).siblings('.spinner')
      spinner.show()
      status = $(self).val()
      p = $.post url, data
      p.fail (jqXHR, textStatus, errorThrown)->
        response = JSON.parse(jqXHR.responseText)
        $("#error_area").text(response.message)
        $("#errors").modal()
      p.always ->
        spinner.hide()


    #Set attr, not data.  Then tell datatables to redraw so search gets updated
    $('.status-select').change ->
      status = $(this).val()
      loan_num = $(this).data('loannum')
      p = post this, "/initial_disclosure/work_queue/#{loan_num}/save_status", {status: status}
      p.success =>
        $(this).parent('td').siblings('.status').html($(this).val())
        $(this).parent('td').attr('data-search',$(this).val())
        work_queue.row($(this).parent('td').parent('tr')).invalidate().draw()

      
    $('.work-queue-assign-to-me').click (e) ->
      loan_num = $(this).data('loannum')
      e.preventDefault()
      p = post this, "/initial_disclosure/work_queue/#{loan_num}/assign_self"
      p.success (result) =>
        $(this).closest('td').html(result)
        $(this).parent('td').siblings('.assignee').html(result)
        $(this).parent('td').attr('data-search',result)
        work_queue.row($(this).parent('td').parent('tr')).invalidate().draw()

    $('.work-queue-assignment-select').change ->
      loan_num = $(this).data('loannum')
      p = post this, "/initial_disclosure/work_queue/#{loan_num}/assign_other", {assignee: $(this).val()}
      p.success =>
        $(this).parent('td').siblings('.assignee').html($(this).val())
        $(this).parent('td').attr('data-search',$(this).val())
        work_queue.row($(this).parent('td').parent('tr')).invalidate().draw()

    $('.initial_title_quote_received').click ->
      loan_num = $(this).data('loannum')
      p = post this, "/initial_disclosure/work_queue/#{loan_num}/save_title_quote", {initial_title_quote_received: $(this).val()}
      p.success =>
        $(this).parent('td').attr('data-search',$(this).val())
        work_queue.row($(this).parent('td').parent('tr')).invalidate().draw()


}
