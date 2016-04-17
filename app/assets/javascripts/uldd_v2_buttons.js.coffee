window.ULDDv2Buttons = {
  initialize: ->
    $("#ulddv2_description").hide()

    links = $("a:contains('Export for Delivery')")
    $("#uldd_version button").click (e) ->
      v = $(this).data("version")
      
      if v == "v2"
        $("#ulddv2_description").show()
        links.each (index, link) ->
          $(link).data('original-href', link.href)
          link.href += "&use_fnma_v2=true"
      else
        $("#ulddv2_description").hide()
        links.each (index, link) ->
          link.href = $(link).data('original-href') || link.href
}
