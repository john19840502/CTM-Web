# $(document).ready ->
#   $(".branch-details").hide()
#   $(".branch-det-link").click (e) ->
#     e.preventDefault()
#     link = $(this)
#     div_area = "#" + link.attr("data-branch-details")
#     $(div_area).toggle()
#     if $(div_area).is(":visible")
#       link.html "<i class='icon-arrow-up'></i> Hide Branch loans and comp plans"
#     else
#       link.html "<i class='icon-arrow-down'></i> Show Branch loans and comp plans"