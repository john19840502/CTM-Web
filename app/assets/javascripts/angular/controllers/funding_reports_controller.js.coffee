fundingReportsController = angular.module('fundingReportsController', ['ui.bootstrap'])

fundingReportsController.controller 'FundingReportsCtrl', [
  "$scope"
  "$http"
  ($scope, $http) ->

    $scope.get_filtered = (search_key, search_value) ->
      $scope.loading_filter = true
      filtered_array = []
      angular.forEach $scope.checklists, ((list, key) -> 
        if list[search_key] == search_value
          @push list
        ), filtered_array
      $scope.loading_filter = false
      $scope.checklists = filtered_array
      paginate(filtered_array)

    paginate = (checklist) ->
      $scope.numPerPage = 10
      $scope.totalCount = checklist.length
      $scope.currentPage = 1
      $scope.$watch 'currentPage + numPerPage', ->
        begin = ($scope.currentPage - 1) * $scope.numPerPage
        end = begin + $scope.numPerPage
        $scope.filteredChecklists = checklist.slice(begin, end) 

    $scope.numPages = ->
      Math.ceil $scope.totalCount / $scope.numPerPage

    arrange_data = (response) ->
      $scope.checklist_loading = false
      $scope.filter = {}
      $scope.search_value = null
      $scope.checklists = response.data.checklist_data
      $scope.promptsList = response.data.prompts
      if response.data.checklist_data.length != 0
        $scope.objectKeys = Object.keys(response.data.checklist_data[0])
      paginate(response.data.checklist_data)

    $scope.get_comparision_checklist = ->
      $scope.checklist_loading = true
      p = $http.get('/funding/reports/comparision.json?start_date='+ $scope.start_date+ "&end_date="+ $scope.end_date)
      p.then (response) ->
        arrange_data(response)
      p.error (e) ->
        $scope.error_panel = true
        $scope.errors = e.data

    $scope.get_checklist = ->
      $scope.checklist_loading = true
      p = $http.get('/funding/reports/report.json?start_date='+ $scope.start_date+ "&end_date="+ $scope.end_date)
      p.then (response) ->
        arrange_data(response)
      p.error (e) ->
        $scope.error_panel = true
        $scope.errors = e.data

]
