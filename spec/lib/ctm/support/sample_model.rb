require 'spec_helper'
require 'ctm/ms_sql_view'
module CTM
  module Support
    class SampleModel < DatabaseDatamartReadonly
      extend CTM::MSSqlView

      # must be defined first or things break....
      from 'CALCULATION', as: 'c'

      # fields
      # - Can also pass source: 'some_table_alias' to create 'some_table_alias.CALCULATION_id'
      field :calculation_id2, column: 'CALCULATION_id2'#, source: 'c'

      # option, corce means turn to calculation_id, otherwise keep original field name
      field_list ['CALCULATION_id', 'SomeOtherId', '_Name'], source: 'd' , coerce: true
      field_list ['CALCULATION_id2', 'SomeOtherId2', '_Name2'], source: 'z' #, coerce: true

      # joins
      join 'ACCOUNT_INFO', on: ['c.CALCULATION_id', 'ai.LoanGeneralId'], as: 'ai', type: :inner

      # will produce c.LoanGeneralId = ai.LoanGeneralId
      join 'ACCOUNT_INFO2', on: 'LoanGeneralId', as: 'a2', type: :inner


      # used to build out the view for datamart.
      def self.sqlserver_create_view
        self.build_query
      end
    end
  end
end
