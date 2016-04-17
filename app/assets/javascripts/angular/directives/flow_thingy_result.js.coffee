app = angular.module('flow-thingy-result-directive', [])

app.directive "flowThingyResult", ->
  restrict: "E"
  scope:
    flow_title: "@flowTitle"
    flow: "=flow"
    flow_name: "=flowName"
    loading_flag: "=loadingFlag"
  templateUrl: "flow_thingy_result.html"
  controller: [
    "$scope"
    ($scope) ->
      $scope.setClass = (flow_status) ->
        if flow_status == 'fail'
          'failing-validation'
        else if flow_status == 'pass'  
          'passing-validation'
        else
          'manual-validation'
        
  ]
