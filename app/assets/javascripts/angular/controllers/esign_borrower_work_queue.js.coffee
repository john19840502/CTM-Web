esignBorrowerQueueController = angular.module('esignBorrowerQueueController', [])

esignBorrowerQueueController.controller 'EsignBorrowerQueueCtrl', [
  "$rootScope"
  "$scope"
  "$http"
  "$q"
  "$location"
  "$window"
  ($rootScope, $scope, $http, $q, $location, $window) ->

    $scope.borrower_completions = []
    $scope.loading_data = false
    $scope.loading_pdf = false

    $scope.loadQueue = ->
      $scope.loading_data = true
      uri = "/esign/borrower_work_queue.json"

      fetchQueue = $http.get(uri)
      fetchQueue.then ((response) ->
        $scope.borrower_completions = response.data.borrower_completions
        $scope.loading_data = false
      ) , (error) ->
        $scope.loading_data = false

    $scope.loadPackageForLoan = (loan_num) ->
      $scope.loading_pdf = true
      uri = "/esign/package_versions/most_recent_for_loan.json?loan_num=" + loan_num

      fetchMostRecentPackage = $http.get(uri)
      fetchMostRecentPackage.then ((response) ->
          package_id = response.data.package_id
          loadPackage(package_id)
          $scope.loading_pdf = false
        ) , (error) ->
          $scope.loading_pdf = false

    loadPackage = (package_id) ->
      $window.open("/esign/documents/" + package_id + "/show.pdf")

    $scope.setStatus = (event) ->
      uri = event.target["action"]["value"] + ".json"
      data = { "status": event.target["status"]["value"] }
      submitForm = $http.put(uri, data)
      submitForm.then ((response) ->
        updateRow(response.data.borrower_completion)
      )


    $scope.assignUser = (event) ->
      uri = event.target["action"]["value"] + ".json"
      id = event.target["id"]["value"]
      override = event.target["override"]["value"]
      data = { "assignee": event.target["assignee"]["value"] }
      
      if override == "true"
        sendUpdate uri, data
      else
        checkAssigned = $http.get("/esign/borrower_work_queue/" + id + ".json")
        checkAssigned.then ((response) ->
          borrower_completion = response.data.borrower_completion
          console.log borrower_completion.assignee
          if borrower_completion.assignee
            borrower_completion.assignment_error = true
            updateRow(borrower_completion)
          else
            sendUpdate uri, data
        )

    sendUpdate = (uri, data) ->
      submitForm = $http.put(uri, data)
      submitForm.then ((response) ->
        updateRow(response.data.borrower_completion)
      )

    updateRow = (bc) ->
      for entry in $scope.borrower_completions
        update_entry = entry if entry.id == bc.id
      update_entry.assignee = bc.assignee
      update_entry.status = bc.status
      update_entry.completed = bc.completed
      update_entry.assignment_error = bc.assignment_error
      if update_entry.completed
        remove(update_entry)

    remove = (entry) ->
      index = $scope.borrower_completions.indexOf(entry)
      $scope.borrower_completions.splice(index, 1)


    $scope.loadQueue()
]