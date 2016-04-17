app = angular.module('is-empty-filter', [])

app.filter 'isEmpty', ->
  (obj) ->
    for bar of obj
      return false if obj.hasOwnProperty(bar)
    true
