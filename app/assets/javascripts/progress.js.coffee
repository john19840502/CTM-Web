$ ->

  # loop through all our records and request a progress update on 
  # any that aren't marked as "completed"
  update_progress = (p) ->
    $('tbody.records').find('tr.record').each ->
      row = $(this)
      status = row.find('td.status-column')
      if ($.trim(status.html()) != 'completed' && $.trim(status.html()) != 'failed')
        progress = row.find(p.result_cell)
        id = $.trim(row.find('td.id-column').html())
        $.ajax
          url: p.progress_url + id + '/progress'
          async: true
          type: "POST"
          success: (resp) ->
            progress.html(resp.progress)
            status.html(resp.status)
            # if a record has transitioned from !completed -> completed then refresh the page
            if (resp.status == 'completed') 
              window.location.reload()

  # only do updates if we have the correct table on the page
  App.do_status_progress_updates = do_status_progress_updates = (p) ->
    return
    if $('tbody.records').size() > 0 and $('tbody.records')[0].id == p.table_id
      # initial update
      update_progress(p)
      # recurring updates every 10 seconds
      setInterval -> 
        update_progress(p)
      , 10000
