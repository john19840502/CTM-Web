module Validation
  module Checklist
    class BuildChecklistResponse
      include ServiceObject

      def initialize definition
        self.definition = definition
      end

      def call
        if checklist.nil?
          return {
            sections: [],
            conclusion: "NOT STARTED",
            warnings: [],
            started: false,
            completed: false,
            status: "fail"
          }
        end

        {
          sections: questions_by_section,
          conclusion: determine_conclusion,
          warnings: [],
          started: true,
          completed: false,
          status: determine_status,
        }
      end

      private

      attr_accessor :definition

      def checklist
        definition.try!(:checklist)
      end

      def loan
        checklist.try!(:loan)
      end

      def determine_warnings
        definition.warnings
      end

      def determine_conclusion
        complete = definition.questions.
          select{|q| q.applicable_to(loan) }.
          all? do |q|
            !q.visible?(checklist, definition) || q.optional? || q.has_valid_answer?(checklist)
          end
        complete ? 'Complete' : 'Incomplete'
      end

      def determine_status
        case determine_conclusion
        when 'Complete' then 'pass'
        else 'fail'
        end
      end

      def questions_by_section
        definition.sections.map do |section|
          { section: section.name,
            questions: questions_for(section)
          }
        end
      end

      def questions_for(section)
        section.questions.
          select{|q| q.applicable_to(loan) }.
          map do |question|
            question.as_json.merge answer: question.answer(checklist), info: question.our_attr(loan) || "", visible: question.visible?(checklist, definition)
          end
      end

    end

  end
end
