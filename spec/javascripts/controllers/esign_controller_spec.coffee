"use strict"

describe "Controller: EsignCtrl", ->
  scope = undefined
  $rootScope = undefined
  beforeEach ->
    module "baseApp" # <= initialize module that should be tested

  beforeEach inject ($controller, _$rootScope_) ->
    $rootScope = _$rootScope_
    scope = $rootScope.$new()
    $controller "EsignCtrl",
      $scope: scope

  it "should add spaces between simple words", ->
    expect(scope.separateWords("InProgress")).toEqual "In Progress"

  it "should handle acronyms", ->
    expect(scope.separateWords("DSIPrintedAndMailed")).toEqual "DSI Printed And Mailed"

  it "should leave single words alone", ->
    expect(scope.separateWords("Consented")).toEqual "Consented"

  it "should handle nil", ->
    expect(scope.separateWords(null)).toEqual null
