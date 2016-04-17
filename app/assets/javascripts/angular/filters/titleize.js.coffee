app = angular.module('titleize-filter', [])

app.filter 'titleize', ->
  (value) ->
    value = value.replace "_", " "
    value.replace /(?:^|\s)\S/g, (a) ->
      a.toUpperCase()
