settlementAgentComparisionReportsController = angular.module('settlementAgentComparisionReportsController', ['ngSanitize', 'ngCsv', 'pickadate-directive', 'highcharts-ng', 'ui.bootstrap'])

settlementAgentComparisionReportsController.controller 'SettlementAgentComparisionReportsCtrl', [
  "$scope"
  "$http"
  "limitToFilter"
  ($scope, $http, limitToFilter) ->

  	$scope.get_monthly_comparision = ->	
  		$http.get("/closing/settlement_agent_audits/comparision_report.json?year=" + $scope.year).then (response) ->
  			$scope.previous_month = response.data.previous_month
  			$scope.current_month = response.data.current_month
  			$scope.agents = response.data.agents
  			$scope.year = response.data.year
  			$scope.years = [2015..response.data.current_year]
  			$scope.headers = []
  			angular.forEach response.data.agents[0], ((value, key) ->
  				@push key
				), $scope.headers

  	$scope.get_monthly_comparision()

  ]
.filter 'removeUnderscore', ->
	(input) ->
    input.replace(/_/g, " ");
