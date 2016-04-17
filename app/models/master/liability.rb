require 'ctm/ms_sql_view'
module Master
  class Liability < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView
    attr_accessible :liability_type, :holder_name, :lien_position, :monthly_payment_amount,
      :unpaid_balance_amount, :reo_id

    # relations
    belongs_to :loan, class_name: 'Master::Loan'

    from 'LIABILITY', as: 'liability'

    field :liability_id,        column: 'LIABILITY_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :borrower_id,         column: 'BorrowerID'
    field :reo_id,              column: 'REO_ID'
    field :holder_name,         column: '_HolderName'
    field :liability_type,      column: '_Type'
    field :lien_position
    field :monthly_payment_amount, column: '_MonthlyPaymentAmount'
    field :unpaid_balance_amount, column: '_UnpaidBalanceAmount'
    field :subject_loan_resubordination_indicator
    field :heloc_maximum_balance_amount, column: 'HELOCMaximumBalanceAmount'
    field :exclusion_indicator,  column: '_ExclusionIndicator'
    field :payoff_status_indicator, column: '_PayoffStatusIndicator'

    alias_attribute :loan_general_id, :loan_id

    # scopes
    scope :primary,       ->{ where(:borrower_id => 'BRW1') }
    scope :secondary,     ->{ where(:borrower_id => 'BRW2') }
    scope :first_lien,    ->{ where(liability_type: 'MortgageLoan', lien_position: 'FirstLien') }
    scope :owned_by_ctm,  ->{ where("holder_name LIKE 'Cole Tay%' OR holder_name LIKE 'CTM'") }

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

    def current_heloc_maximum_balance_amount
      return 0 unless heloc?
      [heloc_maximum_balance_amount, unpaid_balance_amount].max
    end

    def real_reo_property
      ReoProperty.where(loan_id: loan_id, reo_id: reo_id).subject.first
    end

    def owned_by_ctm?
      holder_name =~ /\Actm|\Acole taylor/i
    end

    def resubordination?
      subject_loan_resubordination_indicator
    end

    def unexcluded?
      !exclusion_indicator
    end

    def subordinate_loan?
      secondary_mortgage? || heloc?
    end

    def paying_off?
      payoff_status_indicator
    end

    def secondary_mortgage?
      real_reo_property &&
          resubordination? &&
          unexcluded? &&
          liability_type == 'MortgageLoan' &&
          !paying_off? &&
          unpaid_balance_amount.to_i > 0
    end

    def heloc?
      real_reo_property &&
          resubordination? &&
          unexcluded? &&
          liability_type == 'HELOC' &&
          !paying_off? &&
          (unpaid_balance_amount.to_i > 0 || heloc_maximum_balance_amount > 0)
    end
  end
end
