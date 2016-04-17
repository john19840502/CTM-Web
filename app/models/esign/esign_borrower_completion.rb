module Esign
  
  class EsignBorrowerCompletion < ActiveRecord::Base
    belongs_to :esign_signer

    scope :uncompleted, -> {where("status is null or status != 'Task completed'")}

    def product
      Master::Loan.find_by_loan_num(loan_number).try!(:product_code_translated)
    end

    def complete?
      status == "Task completed"
    end

  end

end