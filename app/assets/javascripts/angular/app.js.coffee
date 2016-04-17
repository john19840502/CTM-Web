app = angular.module('baseApp', ['ui.bootstrap', 'editNoteController', 'templates', 'underwriterValidationController', 'bpeStatisticsController', 'is-empty-filter', 'titleize-filter', 'is-all-filter', 'initialDisclosureValidationController', 'registrationValidationController', 'preclosingValidationController', 'closingValidationController', 'settlementAgentReportsController', 'settlementAgentComparisionReportsController', 'esignConsentController', 'checklistExperimentController', 'closingChecklistService', 'fundingValidationsController', 'fundingReportsController', 'registrationChecklistService', 'eventListingController', 'documentListingController', 'esignController', 'esignBorrowerQueueController'])

app.config [
  "$httpProvider"
  "$locationProvider"
  ($httpProvider, $locationProvider) ->
    $httpProvider.defaults.headers.common["X-CSRF-Token"] = $("meta[name=csrf-token]").attr("content")
    $locationProvider.html5Mode
      enabled: true
]

app.filter "unique", ->
  (input, key) ->
    return if (typeof input == 'undefined')
    unique = {}
    uniqueList = []
    i = 0

    while i < input.length
      if typeof unique[input[i][key]] is "undefined"
        unique[input[i][key]] = ""
        uniqueList.push input[i]
      i++
    uniqueList
