module Funding
  class BuildChecklistQuestions
    include ServiceObject

    def initialize checklist
      self.checklist = checklist
    end

    def call
      {
        questions: build_questions
      }
    end

    private
    attr_accessor :checklist

    def build_questions
      [
        has_the_vvoe_obtained,
        hud_cd_from_previous_home_sale_in_file,
        emailed_escrow_settlement_with_funding_number,
        loan_notes_updated_with_funding_information,
        all_conditions_reviewed_and_signed_off,
        all_documents_uploaded_into_imaging,
        ctm_database_updated,
        qc_date_added_to_mortgagebot,
        assigned_loan_to_youself_in_mortgagebot,
        pdf_of_purchase_advice_created
      ].each do |question|
        checklist_answer_for question
      end
    end

    def checklist_answer_for question
      question.tap do |q|
        q[:answer] = checklist.checklist_answers.find_by(name: q[:attribute]).try(:answer).to_s
      end
    end

    def has_the_vvoe_obtained
      {
        prompt: "Has the VVOE been obtained",
        attribute: "has_the_vvoe_obtained"
      }
    end

    def hud_cd_from_previous_home_sale_in_file
      {
        prompt: "Is the HUD-1/CD from Sale of Previous Home in file and with proper amount?",
        attribute: "hud_cd_from_previous_home_sale_in_file"
      }
    end

    def emailed_escrow_settlement_with_funding_number
      {
        prompt: "Has the email been sent to escrow/ settlement with funding number?",
        attribute: "emailed_escrow_settlement_with_funding_number"
      }
    end

    def loan_notes_updated_with_funding_information
      {
        prompt: "Has Loan Notes been updated with funding information?",
        attribute: "loan_notes_updated_with_funding_information"
      }
    end

    def all_conditions_reviewed_and_signed_off
      {
        prompt: "Have all conditions been reviewed and signed off",
        attribute: "all_conditions_reviewed_and_signed_off"
      }
    end

    def all_documents_uploaded_into_imaging
      {
        prompt: "Have all documents been uploaded into imaging?",
        attribute: "all_documents_uploaded_into_imaging"
      }
    end

    def ctm_database_updated
      {
        prompt: "Has the CTM database been updated?",
        attribute: "ctm_database_updated"
      }
    end

    def qc_date_added_to_mortgagebot
      {
        prompt: "Has the Q.C. date been added to MortgageBot?",
        attribute: "qc_date_added_to_mortgagebot"
      }
    end

    def assigned_loan_to_youself_in_mortgagebot
      {
        prompt: "Did you assign the loan to yourself in MortgageBot?",
        attribute: "assigned_loan_to_youself_in_mortgagebot"
      }
    end

    def pdf_of_purchase_advice_created
      {
        prompt: "Has a PDF of the Purchase Advice been created?",
        attribute: "pdf_of_purchase_advice_created"
      }
    end
  end
end