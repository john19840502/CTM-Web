module Mdb
  class ValidationCharts
    include Mongoid::Document

    field :decision_dates, type: Array
    field :non_valid_loans, type: Array
    field :decision_flow_errors, type: Array
    field :non_valid_loans_list, type: Array
    field :statistic_report_id, type: Integer
    field :created_by, type: String
    field :created_at, type: DateTime

  end
end
