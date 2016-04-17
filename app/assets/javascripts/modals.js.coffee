# Creates a modal window
# To use:
# 1. data-toggle='modal' must be added to the link
# 2. data-url holds the url to be loaded into the modal
# 3. data-title gives a title for the modal
$(document).ready ->
  $(document).on 'click', "a[data-toggle='modal']", (event) ->
    # data-modal-options is a hash of optional params - height, width, top, and margin-left - i.e. {'height':800, 'width': 1200}
    App.load_nested_modal($(this).attr('data-url'), $(this).attr('data-title'), $(this).attr('data-modal-options'))

  modal_dia = '<div class="modal hide" id="nested_modal">' +
    '<div class="modal-header">' +
    '<button type="button" class="close" data-dismiss="modal">×</button>' +
    '<h3>&nbsp;</h3>' +
    '</div>' +
    '<div class="modal-body">' +
    '<p id="modal_contents">Loading…</p>' +
    '</div>' +
    '</div>'

  $('#footer').append(modal_dia)

  $('#nested_modal').on 'hidden', () ->
    $('#modal_contents').html('Loading...')

App.load_nested_modal = load_nested_modal = (url, title, args) ->

  args = { 'width': 1200, 'height': 800, 'top': 300, 'margin_left': -600 } if typeof args == 'undefined'

  width = args['width'] || 1200
  height = args['height'] || 800
  top = args['top'] || 300
  margin_left = args['margin_left'] || -600

  $('.modal').css('top', top + 'px').css('width', width + 'px').css('height', height + 'px').css('margin-left', margin_left + 'px')
  $('.modal button').css 'opacity', '1'
  $('.modal-header h3').text title
  
  $('.modal-body').css('max-height', '700px')
  $('.modal-body').css('width', (width - 30))

  $('#nested_modal').modal()
  $('#modal_contents').load url
