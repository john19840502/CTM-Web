app = angular.module('processValidationsService', [])

app.factory 'ProcessValidationsService', [
  "$http"
  ($http) ->
    
    processValidationsService = {}

    processValidationsService.run = (id, event_id) ->
      $http.get '/underwriter/validations/process_validations.json?id=' + id + '&event_id=' + event_id

    return processValidationsService
]
