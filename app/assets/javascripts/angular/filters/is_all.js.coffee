app = angular.module('is-all-filter', [])

app.filter 'isAll', ->
  (val) ->
    if not val? or val is false
      return "All"
    else
      return val
    
