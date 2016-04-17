app = angular.module('flowService', [])

app.factory 'FlowService', [
  "$http"
  ($http) ->
    
    flowServiceFactory = {}

    flowServiceFactory.run = (id, flow, event_id, validation_type) ->
      $http.get '/decisionator_flows/validations.json?id=' + id + "&flow=" + flow + "&event_id=" + event_id + "&validation_type=" + validation_type

    return flowServiceFactory
]

