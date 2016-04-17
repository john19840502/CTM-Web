module Closing::SettlementAgent
  class BuildSettlementAgentQuestions
    include ServiceObject

    def initialize audit
      self.audit = audit
    end

    def options type
      case type
      when 'multi_items'
        ['Yes', 'No', 'NA']
      when 'no_items'
        ['NA', 'No']
      when 'yes_no'
        ['Yes', 'No']
      end
    end

    def call
      {
        questions: build_questions
      }
    end

    private
    attr_accessor :audit

    def build_questions
    end
  end
end