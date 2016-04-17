esignConsentController = angular.module('esignConsentController', [])

esignConsentController.controller 'EsignConsentCtrl', [
  "$rootScope"
  "$scope"
  "$http"
  "$q"
  "$window"
  ($rootScope, $scope, $http, $q, $window) ->
    $scope.consent_actions = {}
    $scope.consent_completes = {}
    $scope.consent_data_saved = {}
    $scope.error_saving_consent_data = {}
    $scope.error_saving_consent_message = {}

    $scope.processConsentAction = (consent_id) ->
      is_complete = $scope.consent_completes[consent_id]
      if is_complete
        $scope.updateConsent(consent_id, $scope.consent_actions[consent_id], is_complete)

    $scope.processConsentComplete = (consent_id) ->
      is_complete = $scope.consent_completes[consent_id]
      action = $scope.consent_actions[consent_id]
      if is_complete && action
        $scope.updateConsent(consent_id, action, is_complete)
      else if !is_complete
        $scope.updateConsent(consent_id, '', is_complete)

    $scope.goPath = (path) ->
      $window.location.href = path

    $scope.updateConsent = (consent_id, action, complete) ->
      $scope.consent_data_saved = {}
      $scope.error_saving_consent_data = {}
      $scope.error_saving_consent_message = {}

      sendUpdate = $http.get("/registration/esign_consent/create.json?id=" + consent_id + "&consent_action=" + action + "&consent_complete=" + complete)

      sendUpdate.then ((response) ->
        $scope.consent_data_saved[consent_id] = true
      ), (error) ->
        $scope.error_saving_consent_data[consent_id] = true
        $scope.error_saving_consent_message[consent_id] = error.data.error
]