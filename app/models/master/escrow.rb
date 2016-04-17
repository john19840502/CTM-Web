require 'ctm/ms_sql_view'
module Master
  class Escrow < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    # relations
    belongs_to :loan, class_name: 'Master::Loan'

    from 'ESCROW', as: 'escrow'

    field :loan_id,                                     column: 'loanGeneral_Id'
    field :collected_number_of_months_count,            column: '_CollectedNumberOfMonthsCount'
    field :due_date,                                    column: '_DueDate'
    field :second_due_date,                             column: '_SecondDueDate'
    field :third_due_date,                              column: '_ThirdDueDate'
    field :fourth_due_date,                             column: '_FourthDueDate'
    field :item_type,                                   column: '_ItemType'
    field :item_type_other_description,                 column: '_ItemTypeOtherDescription'
    field :payment_frequency_type,                      column: '_PaymentFrequencyType'
    field :gfe_disclosed_premium_amount,                column: 'GFEDisclosedPremiumAmount'

    alias_attribute :loan_general_id, :loan_id

    # scopes

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

    def hud_line(disbursement_name, hud_type = 'HUD')
      loan.hud_lines.where(line_num: Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_name.to_sym], hud_type: hud_type).where("monthly_amount > 0").first 
    end

    def is_other?
      item_type == 'Other'  
    end

  end
end
