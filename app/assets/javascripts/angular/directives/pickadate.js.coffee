app = angular.module('pickadate-directive', [])

app.directive "pickADate", ->
  restrict: "A"
  scope:
    pickADate: "="

  link: (scope, element, attrs) ->
    updateValue = (newValue) ->
      if newValue
        scope.pickADate = (if (newValue instanceof Date) then newValue else new Date(newValue))
        
        # needs to be in milliseconds
        element.pickadate("picker").set "select", scope.pickADate.getTime()
      else
        element.pickadate("picker").clear()
        scope.pickADate = null
      
    element = $(element)
    element.pickadate
      onSet: (e) ->
        return  if scope.$$phase or scope.$root.$$phase
        select = element.pickadate("picker").get("select")
        scope.$apply ->
          if e.hasOwnProperty("clear")
            scope.pickADate = null

          return if !select
            
          unless scope.pickADate
            now = new Date(0)
            now = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),  now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds())
            scope.pickADate = now
          scope.pickADate.setYear select.obj.getFullYear()
          scope.pickADate.setMonth select.obj.getMonth()
          scope.pickADate.setDate select.obj.getDate()
        

      onClose: ->
        element.blur()
        

      monthsFull: attrs.monthsFull
      monthsShort: attrs.monthsShort
      weekdaysFull: attrs.weekdaysFull
      weekdaysShort: attrs.weekdaysShort
      showMonthsShort: attrs.showMonthsShort
      showWeekdaysFull: attrs.showWeekdaysFull
      today: (if (attrs.today isnt `undefined`) then attrs.today else "Today")
      clear: (if (attrs.clear isnt `undefined`) then attrs.clear else "Clear")
      labelMonthNext: (if (attrs.labelMonthNext isnt `undefined`) then attrs.labelMonthNext else "Next month")
      labelMonthPrev: (if (attrs.labelMonthPrev isnt `undefined`) then attrs.labelMonthPrev else "Previous month")
      labelMonthSelect: (if (attrs.labelMonthSelect isnt `undefined`) then attrs.labelMonthSelect else "Select a month")
      labelYearSelect: (if (attrs.labelYearSelect isnt `undefined`) then attrs.labelYearSelect else "Select a year")
      format: attrs.format
      formatSubmit: attrs.formatSubmit
      hiddenPrefix: attrs.hiddenPrefix
      hiddenSuffix: attrs.hiddenSuffix
      hiddenName: attrs.hiddenName
      editable: attrs.editable
      selectYears: (attrs.selectYears is "true")
      selectMonths: (attrs.selectMonths is "true")
      firstDay: attrs.firstDay
      disable: attrs.disable

    updateValue scope.pickADate
    scope.$watch "pickADate", ((newValue, oldValue) ->
      return  if newValue is oldValue
      updateValue newValue
      return
    ), true