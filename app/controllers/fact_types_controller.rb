class FactTypesController < ApplicationController
  def index
  end

  def search
    @loan = Loan.find_by_id(params[:loan_id]) || TestLoan.find_by_id(params[:loan_id])
    extra_fact_types = Array(params[:extra_fact_type])
    if @loan
      @flow_results = {}

      if extra_fact_types.any?
        ft = Decisions::Facttype.new("aus", {loan: @loan, debug: true})
        @flow_results["Extra Fact Types"] = extra_fact_types.inject({}) do |hash, fact_type_name|
          hash[fact_type_name] = 
            begin
              ft.send fact_type_name.underscore
            rescue => e
              hash[fact_type_name] = "Failed to calculate #{fact_type_name}:  #{e.message}"
            end
          hash
        end
      end

      Decisions::Flow::FLOWS.each do |key,val|
        @flow_results[key.to_s.humanize] =
          begin
            Decisions::Facttype.new(key, {loan: @loan, debug: true}).execute
          rescue => e
            "Failed to query fact types for flow #{key}, which has value #{val}.  Message:  #{e.message}"
          end
      end

      @flow_results
    end
  end
end

