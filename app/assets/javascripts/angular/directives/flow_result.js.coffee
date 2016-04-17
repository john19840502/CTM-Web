app = angular.module('flow-result-directive', [])

app.directive "flowResult", ->
  restrict: "E"
  scope:
    flow_title: "@flowTitle"
    flow_name: "=flowName"
    loading_flag: "=loadingFlag"
    popover_text: "@popoverText"
    expand_text: "@expandText"
  templateUrl: "flow_result.html"
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
