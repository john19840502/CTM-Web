"use strict"

describe "Controller: UwValidationCtrl", ->
  scope = undefined
  $rootScope = undefined

  beforeEach ->
    module "baseApp" # <= initialize module that should be tested

  beforeEach inject ($controller, _$rootScope_) ->
    $rootScope = _$rootScope_
    scope = $rootScope.$new()
    $controller "UwValidationCtrl",
      $scope: scope

  it "performsValidations when rootscope emits a ValidationWarningProcessed eve t", ->
    scope.performValidations = jasmine.createSpy 'performValidations'
    $rootScope.$emit 'ValidationWarningProcessed'
    expect(scope.performValidations).toHaveBeenCalled()
