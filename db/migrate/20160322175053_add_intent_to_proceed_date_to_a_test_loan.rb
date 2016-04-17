class AddIntentToProceedDateToATestLoan < ActiveRecord::Migration
  def up
    return unless Rails.env.development?

    p 'starting insert to Custom Fields in LENDER_LOAN_SERVICE.[CUSTOM_FIELD] ============='

    execute %Q{
      /* Additional supporting data for loan 1022358 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[CUSTOM_FIELD] ([LoanGeneral_Id],[FormUniqueName],[AttributeUniqueName],[AttributeValue]) VALUES (751,'Registration Tracking','RegTrackingITPDate','20101116 10:36:88 AM');
    }
  end
end
