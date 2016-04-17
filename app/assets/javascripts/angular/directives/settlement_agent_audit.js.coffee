app = angular.module('settlement-agent-directive', ['settlementAgentAuditService'])
app.directive "settlementAgentAudit", ->
  restrict: "E"
  transclude: true
  scope:
    loan_number: "=loanNumber"

  templateUrl: "settlement_agent_audit.html"
  controller: SettlementAgentAuditCtrl
  controllerAs: 'ctrl'

class SettlementAgentAuditCtrl
  constructor: ($rootScope, $scope, $http, auditService, limitToFilter) ->
    this.$rootScope = $rootScope
    this.$scope = $scope
    this.$http = $http
    this.auditService = auditService
    this.limitToFilter = limitToFilter

  agentName: (name) ->
    p = this.$http.get("/escrow_agents/agent_name?term=" + name)
    p.then (response) =>
      this.limitToFilter response.data, 15

  agentAddress: (addr) ->
    p = this.$http.get("/escrow_agents/agent_addr?term=" + addr)
    p.then (response) =>
      this.limitToFilter response.data, 15

  agentCity: (city) ->
    p = this.$http.get("/escrow_agents/agent_city?term=" + city)
    p.then (response) =>
      this.limitToFilter response.data, 15

  agentState: (state) ->
    p = this.$http.get("/escrow_agents/agent_state?term=" + state)
    p.then (response) =>
      this.limitToFilter response.data, 15

  agentZipcode: (zip) ->
    p = this.$http.get("/escrow_agents/agent_zip?term=" + zip)
    p.then (response) =>
      this.limitToFilter response.data, 15

  isPurchase: (loan_type) ->
    if loan_type == 'Purchase'
      true
    else
      false

  isRefinance: (loan_type) -> 
    if loan_type == 'Refinance'
      true
    else
      false

  getAudit: ->
    this.$scope.escrow_agent = {}
    this.$scope.loading =true
    p = this.auditService.getAudit()
    p.then (response) =>
      this.$scope.audit     = response.data.audit
      this.$scope.trid_loan = response.data.trid_loan
      this.$scope.loan_type = response.data.loan_type
      escrow_id             = this.$scope.audit.escrow_agent_id
      unless escrow_id == null
        escrow_agent = this.auditService.getEscrow(escrow_id)
        escrow_agent.then (response) =>
          this.$scope.escrow_agent = response.data
     
  loadAudit: ->
    this.getAudit()
    this.$scope.load_audit = true
    this.$scope.done_audit = false
    this.$scope.error_panel = false
    this.$scope.items        = [ 'Yes' , 'No'  ]
    this.$scope.multi_items  = ['Yes', 'No', 'NA']
    this.$scope.nortc_items  = [ 'NA' , 'No'  ]   
    p = this.auditService.isTeamLead()
    p.then (response) =>
      this.$scope.team_lead = response.data

  saveAudit: ->
    if Object.keys(this.$scope.escrow_agent).length != 0
      this.saveEscrow()
    else
      this.saveSettlementAgent()

  saveSettlementAgent: ->
    p = this.auditService.saveAudit(this.$scope.audit, this.$scope.trid_loan)
    p.then (response) =>
      this.$scope.load_audit = false
      this.$scope.done_audit = true
      this.$rootScope.$emit('SettlementAgentProcessed', response.data)
    p.catch (error) =>
      this.$scope.error_panel  = true 
      this.$scope.errors       = error.data.errors
      this.$scope.error_msg    = "Cannot proceed. Settlement Agent failed to save due to errors."

  saveEscrow: ->
    p = this.auditService.saveEscrow(this.$scope.escrow_agent)
    p.then (r) =>
      this.$scope.escrow_agent = r.data
      this.$scope.audit['escrow_agent_id'] = this.$scope.escrow_agent.id
      this.saveSettlementAgent()
    p.catch (error) =>
      this.$scope.error_panel  = true
      this.$scope.errors       = error.data.errors
      this.$scope.error_msg    = "Cannot proceed. Escrow Agent failed to save due to errors."

  closeAudit: ->
    this.$scope.load_audit = false
    this.$scope.done_audit = false

SettlementAgentAuditCtrl.$inject = ["$rootScope", "$scope", "$http", "SettlementAgentAuditService", "limitToFilter"]
window.SettlementAgentAuditCtrl = SettlementAgentAuditCtrl