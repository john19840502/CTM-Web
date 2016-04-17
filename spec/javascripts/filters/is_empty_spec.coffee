(->
  "use strict"
  
  describe "Filter: isEmpty", ->
    beforeEach ->
      module "is-empty-filter" # <= initialize module that should be tested

    it "has a isEmpty filter", inject ($filter) ->
      expect($filter("isEmpty")).not.toBeNull()

    it "determines if an object has 'own' properties or not", inject (isEmptyFilter) ->
      expect(isEmptyFilter({})).toBeTruthy()
      expect(isEmptyFilter(hello: "world")).toBeFalsy()
)()
