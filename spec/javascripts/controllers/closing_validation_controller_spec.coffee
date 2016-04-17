"use strict"

describe "Controller: ClosingValidationCtrl", ->
  scope = undefined
  $rootScope = undefined
  beforeEach ->
    module "baseApp" # <= initialize module that should be tested

  beforeEach inject ($controller, _$rootScope_) ->
    $rootScope = _$rootScope_
    scope = $rootScope.$new()
    scope.audit_agent_conclusion = {}
    $controller "ClosingValidationCtrl",
      $scope: scope

  it "returns 'failing-validation' when flow has a status fail", ->
    flow_status = 'fail'
    expect(scope.setClass(flow_status)).toEqual "failing-validation"

  it "returns 'passing-validation' when flow has a status pass", ->
    flow_status = 'pass'
    expect(scope.setClass(flow_status)).toEqual "passing-validation"

  it "should perform validations when rootscope gets a ValidationWarningProcessed event", ->
    scope.performValidations = jasmine.createSpy 'performValidations'
    $rootScope.$emit 'ValidationWarningProcessed'
    expect(scope.performValidations).toHaveBeenCalled()
