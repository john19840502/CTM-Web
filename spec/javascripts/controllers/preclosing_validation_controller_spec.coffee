"use strict"

describe "Controller: PreclosingValidationCtrl", ->
  scope = undefined
  $rootScope = undefined

  beforeEach ->
    module "baseApp" # <= initialize module that should be tested

  beforeEach inject ($controller, _$rootScope_) ->
    $rootScope = _$rootScope_
    scope = $rootScope.$new()
    $controller "PreclosingValidationCtrl",
      $scope: scope

  it "returns 'failing-validation' when flow has a status fail", ->
    flow_status = 'fail'
    expect(scope.setClass(flow_status)).toEqual "failing-validation"

  it "returns 'passing-validation' when flow has a status pass", ->
    flow_status = 'pass'
    expect(scope.setClass(flow_status)).toEqual "passing-validation"

  it "performsValidations when rootscope emits a ValidationWarningProcessed eve t", ->
    scope.performValidations = jasmine.createSpy 'performValidations'
    $rootScope.$emit 'ValidationWarningProcessed'
    expect(scope.performValidations).toHaveBeenCalled()
