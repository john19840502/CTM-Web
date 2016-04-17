bpeStatisticsController = angular.module('bpeStatisticsController', ['pickadate-directive', 'highcharts-ng', 'ui.bootstrap'])

bpeStatisticsController.controller 'BpeStatisticsCtrl', [
  "$scope"
  "$http"
  "limitToFilter"
  ($scope, $http, limitToFilter) ->
    $scope.submitted = false
    $scope.approved = []
    
    $scope.getExport = (reportId) ->
      $http.get("/bpm/statistic_reports/" + reportId + "/export").then (response) ->
        hiddenElement = document.createElement("a")
        hiddenElement.href = "data:attachment/csv," + encodeURI(response.data)
        hiddenElement.target = "_blank"
        hiddenElement.download = "statistic_report_" + reportId + ".csv"
        hiddenElement.click()

    $scope.printPage = () ->
      window.print()

    get_prior_searches = ->
      $http.get("/bpm/statistic_reports/prior_searches.json").then (response) ->
        $scope.prior_searches = response.data

    get_prior_searches()

    $scope.underwriters = (underwriterName) ->
      $http.get("/bpm/statistic_reports/underwriters?term=" + underwriterName).then (response) ->
        limitToFilter response.data, 15

    $scope.markAsReviewed = (error) ->
      toggleClass(error)
      $http.get("/bpm/statistic_reports/mark_as_reviewed?report_id=" + error.report_id + "&error_id=" + error.error_id).then ->
        removeRow($scope.approved_errors, "error_id", error.error_id)

    toggleClass = (error) ->
      $scope.approvedClass = error.error_id
    
    removeRow = (array, property, value) ->
      $.each array, (index, result) ->
        array.splice index, 1  if result[property] is value

    showLoadingCharts = ->
      $scope.loanDecisionsChartConfig =
          loading: true
          title:
            text: "Total Loans with Decision Dates"
        $scope.decisionsErrorsChart =
          loading: true
          title:
            text: "Total Errors by Decision Flow"
        $scope.notValidatedChart =
          loading: true
          title:
            text: "Non-Validated Loans - Current Display"
        $scope.notValidatedChartStatic =
          loading: true
          title:
            text: "Non-Validated Loans - Static Display"

    $scope.viewReport = (report) ->
      showLoadingCharts()
      $scope.report = report
      $http.get("/bpm/statistic_reports/" + report.id + ".json").then (data) ->
        report = data.data

        $scope.approved_errors = report.statistics_hash.approved_errors
        $scope.non_valid_loans = report.statistics_hash.not_validated_list
        $scope.predicate = 'initial_decision_date'

        $scope.loanDecisionsChartConfig =
          options:
            chart:
              type: "column"

            legend:
              layout: "vertical"
              align: "bottom"
              verticalAlign: "bottom"
              borderWidth: 0

            tooltip:
              formatter: ->
                "<b>" + @x + "</b><br/>" + @series.name + ": " + @y + "<br/>" + "Total: " + @point.stackTotal

            plotOptions:
              column:
                stacking: "normal"
                dataLabels:
                  enabled: true
                  color: (Highcharts.theme and Highcharts.theme.dataLabelsColor) or "white"
                  style:
                    textShadow: "0 0 3px black, 0 0 3px black"
          title:
            text: "Total Loans with Decision Dates"
          xAxis:
            categories: [
              "Day 10"
              "Day 9"
              "Day 8"
              "Day 7"
              "Day 6"
              "Day 5"
              "Day 4"
              "Day 3"
              "Day 2"
              "Selected Day"
            ]

          yAxis:
            min: 0
            title:
              text: "# of Loans"

            stackLabels:
              enabled: true
              style:
                fontWeight: "bold"
                color: (Highcharts.theme and Highcharts.theme.textColor) or "gray"

          series: report.statistics_hash.loan_decisions_chart
          loading: false

        $scope.decisionsErrorsChart =
          options:
            chart:
              type: "column"

            plotOptions:
              line:
                dataLabels:
                  enabled: false

                enableMouseTracking: true
            legend:
              layout: "vertical"
              align: "bottom"
              verticalAlign: "bottom"
              borderWidth: 0
            tooltip:
              valueSuffix: " errors"

          title:
            text: "Total Errors by Decision Flow"
            x: -20
          xAxis:
            categories: [
              "Day 10"
              "Day 9"
              "Day 8"
              "Day 7"
              "Day 6"
              "Day 5"
              "Day 4"
              "Day 3"
              "Day 2"
              "Selected Day"
            ]

          yAxis:
            title:
              text: "# of errors"
            plotLines: [
              value: 0
              width: 1
              color: "#808080"
            ]
            min: 0

          series: report.statistics_hash.decision_errors_chart
          loading: false

        # $scope.notValidatedChart =
        #   options:
        #     chart:
        #       type: "line"

        #     plotOptions:
        #       line:
        #         dataLabels:
        #           enabled: false

        #         enableMouseTracking: true
        #     legend:
        #       layout: "vertical"
        #       align: "bottom"
        #       verticalAlign: "bottom"
        #       borderWidth: 0
        #     tooltip:
        #       valueSuffix: " loans"

        #   title:
        #     text: "Non-Validated Loans - Current Display"
        #     x: -20
        #   xAxis:
        #     categories: [
        #       "Day 10"
        #       "Day 9"
        #       "Day 8"
        #       "Day 7"
        #       "Day 6"
        #       "Day 5"
        #       "Day 4"
        #       "Day 3"
        #       "Day 2"
        #       "Selected Day"
        #     ]

        #   yAxis:
        #     title:
        #       text: "# of loans"
        #     plotLines: [
        #       value: 0
        #       width: 1
        #       color: "#808080"
        #     ]
        #     min: 0

        #   series: report.statistics_hash.not_validated_chart
        #   loading: false
        
        # $scope.notValidatedChartStatic =
        #   options:
        #     chart:
        #       type: "line"

        #     plotOptions:
        #       line:
        #         dataLabels:
        #           enabled: false

        #         enableMouseTracking: true
        #     legend:
        #       layout: "vertical"
        #       align: "bottom"
        #       verticalAlign: "bottom"
        #       borderWidth: 0
        #     tooltip:
        #       valueSuffix: " loans"

        #   title:
        #     text: "Non-Validated Loans - Static Display"
        #     x: -20
        #   xAxis:
        #     categories: [
        #       "Day 10"
        #       "Day 9"
        #       "Day 8"
        #       "Day 7"
        #       "Day 6"
        #       "Day 5"
        #       "Day 4"
        #       "Day 3"
        #       "Day 2"
        #       "Selected Day"
        #     ]

        #   yAxis:
        #     title:
        #       text: "# of loans"
        #     plotLines: [
        #       value: 0
        #       width: 1
        #       color: "#808080"
        #     ]
        #     min: 0

        #   series: report.statistics_hash.not_validated_chart_static
        #   loading: false
    
    $scope.createReport = ->
      $scope.approved_errors = null
      $scope.non_valid_loans = null

      data = 
        bpm_statistic_report:
          underwriter: $scope.underwriter
          region: $scope.region
          end_date: $scope.end_date

      if $scope.statisticReportForm.$valid
        showLoadingCharts()

        $http.post("/bpm/statistic_reports.json", data).then (data) ->
          new_report = data.data
          get_prior_searches()
          $scope.viewReport(new_report)
      else
        $scope.submitted = true

    $scope.clearFilters = ->
      $scope.end_date = null
      $scope.underwriter = null
      $scope.region = null
      $scope.inputDropdown = ''

]
