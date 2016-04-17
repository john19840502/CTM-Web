window.Services ||= {}
class window.Services.ClosingChecklistService
  constructor: ($http, $q) ->
    this.$http = $http
    this.$q = $q
    this.checklist = null
    this.loanNumber = undefined
    @loadCallbacks = []

  getChecklist: ->
    throw "loan number missing" unless this.loanNumber
    p = this.$http.get "/closing/checklists/#{this.loanNumber}"
    p.success (response) =>
      this.checklist = response
      this.checklistLoaded()
    p.error (response) =>
      this.checklist = { conclusion: { status: 'fail', error_response: response.message } }

  createNewChecklist: ->
    p = this.$http.post "/closing/checklists/#{this.loanNumber}"
    p.success (response) =>
      this.checklist = response

  saveAnswer: (name, answer) ->
    throw "loan number missing" unless this.loanNumber
    this.$http.put "/closing/checklists/#{this.loanNumber}", {name: name, answer: answer}

  whenChecklistLoads: (callback) ->
    @loadCallbacks.push callback

  checklistLoaded: ->
    _.each @loadCallbacks, (callback) => callback(@checklist)

Services.ClosingChecklistService.$inject = ['$http', '$q']
app = angular.module('closingChecklistService', [])
app.service 'ClosingChecklistService', Services.ClosingChecklistService
