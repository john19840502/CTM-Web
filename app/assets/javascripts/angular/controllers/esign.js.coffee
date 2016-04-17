esignController = angular.module('esignController', [])

esignController.controller 'EsignCtrl', [
  "$rootScope"
  "$scope"
  "$http"
  "$q"
  "$location"
  ($rootScope, $scope, $http, $q, $location) ->

    $scope.getListings = (click_param = null) ->
      resetListings()

      uri = "/esign/event_listings/search.json?"

      if click_param == null
        uri += "start_date=" + $scope.start_date + "&loan_num=" + $scope.loan_number
      else
        if click_param == 'prev_day'
          uri += "start_date=" + $scope.previous_date + "&loan_num=" + $scope.loan_number
        else if click_param == 'next_day'
          uri += "start_date=" + $scope.next_date + "&loan_num=" + $scope.loan_number
        else
          uri += "loan_num=" + click_param.target.text.replace /^\s+|\s+$/g, ""

      fetchListings = $http.get(uri)

      fetchListings.then ((response) ->
        $scope.loading_events = false
        $scope.event_listings = response.data.event_listings
        $scope.search_type = response.data.search_type
        $scope.search_term = response.data.search_term
        $scope.previous_date = response.data.previous_date
        $scope.next_date = response.data.next_date
      ), (error) ->
        $scope.loading_events = false

    resetListings = ->
      $scope.loading_events = true
      $scope.listings = null
      $scope.filter_date = null

    $scope.separateWords = (input) ->
      return input if input is null
      input.replace(/([A-Z]+)([A-Z][a-z])/g, "$1 $2").replace(/([a-z\d])([A-Z])/g, "$1 $2")

    #$scope.getListings()
]