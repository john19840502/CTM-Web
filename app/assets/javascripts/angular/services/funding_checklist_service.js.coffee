window.Services ||= {}
class window.Services.FundingChecklistService
  constructor: ($http, $q) ->
    this.$http = $http
    this.$q = $q
    this.checklist = null
    this.loanNumber = undefined
    @deferred = null

  getChecklist: ->
    throw "Loan Number is missing" unless this.loanNumber
    @deferred = this.$q.defer()
    p = this.$http.get "/funding/checklists/#{this.loanNumber}"
    p.success (response) =>
      this.checklist = response
      @deferred.resolve(response)
    p.error (response) =>
      this.checklist = {coonclusion: { status: 'fail', error_response: response.message}}
      @deferred.reject(response.message)
    @deferred.promise

  saveChecklist: (checklist, button) ->
    throw "Loan number is missing" unless this.loanNumber
    p = this.$http.post "/funding/checklists/#{this.loanNumber}"
    p.success (response) =>
      this.$http.put "/funding/checklists/#{this.loanNumber}", {checklist, button}

  whenChecklistLoads: ->
    @deferred.promise
    
Services.FundingChecklistService.$inject = ['$http', '$q'] 
app = angular.module('fundingChecklistService', [])
app.service 'FundingChecklistService', Services.FundingChecklistService