class Accounting::ScheduledFundingsController < RestrictedAccessController
    

  load_and_authorize_resource class: AccountingScheduledFunding


  active_scaffold :accounting_scheduled_funding do |config|
    config.label = 'Fundings Scheduled'

    config.columns = [:disbursement_date,
                      :loan_id,
                      :borrower_last_name,
                      :title_company,
                      :loan_amount,
                      :net_loan_disbursement,
                      :total_disbursed_amount,
                      :variance,
                      :bank_name,
                      :branch,
                      :aba_number,
                      :account_number
                    ]

    # There isn't room in the table for these columns and they are usually empty anyway
    config.show.columns << [:further_credit_to,
                            :further_aba_number,
                            :further_account_number,
                            :further_reference_number,
                            :bank2_name,
                            :bank2_aba_number,
                            :bank2_account_number]

    config.columns[:loan_id].options = { format: :none }
    config.columns[:loan_amount].options = { format: :currency }
    config.columns[:net_loan_disbursement].options = { format: :currency }
    config.columns[:total_disbursed_amount].options= { format: :currency }
    config.columns[:variance].options= { format: :currency }

    config.actions.exclude :create
    config.actions.exclude :update
    config.actions.exclude :delete
    config.actions.exclude :new
    config.actions.exclude :edit
  end
end
