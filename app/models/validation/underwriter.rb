require 'bpm/stats_recorder' 

module Validation  
  module Underwriter
    
    def self.do_checks loan, user
    
      l = LoanValidation.new loan
      cnt = 0
       
      methods_to_call('Validation::Underwriter::LoanValidation').each do |m|
        l.send m
        cnt += 1
      end

      { errors: prepare_messages(loan, l.errors),
        warnings: prepare_messages(loan, l.warnings),
        info: "Total of #{cnt} validations performed."
      }
    end
    
    def self.methods_to_call(klass)
      klass.constantize.instance_methods(false) 
    end

    def self.prepare_messages loan, messages
      messages_with_rule_id = messages.map do |m| 
        { rule_id: Decisions::Flow::UNDERWRITER_VALIDATION_RULE_ID, 
          text: m
        }
      end
      AppendValidationWarningHistory.call messages_with_rule_id, loan.id
    end

  end
end
