module Validation  
  module Underwriter
    module FactTypes

      def dti_acceptance_message
        return_fact_type_message("Decisions::DtiAcceptance", 63)
      end

      def aus_acceptance_message
        return_fact_type_message("Decisions::AusAcceptance", '')
      end

      def assets_acceptance_message
        return_fact_type_message("Decisions::AssetsAcceptance", '')
      end

      def hpml_compliance_message
        return_fact_type_message("Decisions::HpmlCompliance", '')
      end

      # def other_data_1003_message
      #   return_fact_type_message("Decisions::OtherData")
      # end

      private

      def add_warning(*args)
        @loan.errors[:warning] << args
      end

      def add_error(*args)
        @loan.errors[:base] << args
      end

      def get_results(flow)
        @results = flow.constantize.new(@loan.fact_types).execute
      end

      def return_fact_type_message(flow, rule_id)
        get_results(flow)
        return_warning_messages(rule_id)
        return_error_messages
      end

      def return_error_messages
        complete = @results[:complete]
        messages = @results[:stop_messages]
        unless complete
          messages.each do |message|
            add_error message if message.present?
          end
        end
      end

      def return_warning_messages(rule_id)
        warning = @results[:warning_messages]
        warning.each do |message|
          add_warning rule_id, message if message.present? && rule_id.present?
        end
      end

    end
  end
end
