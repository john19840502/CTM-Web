class PopulateEsignLoanEvents < ActiveRecord::Migration

  def up
    return unless Rails.env.development?

    p 'starting inserts Esign Loan ======================='

    execute %Q{
      /* TRID loan 1001116, cancelled, no disclosure */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] ([LenderDTDVersionID],[LenderRegistrationIdentifier],[loanStatus],[RequestDateTime],[User_Id]) VALUES ('3.0', '1001116', 20, '20150702 10:34:09 AM', 367);
    }

    execute %Q{
      /* Supporting data for loan 1001116 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[BORROWER] ([BorrowerID],[_LastName],[_FirstName],[_EmailAddress],[_ApplicationSignedDate],[loanGeneral_Id]) VALUES ('BRW1', 'Borrower', 'S.', 'sborrower@fake.foo', '20150702 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] ([InstitutionIdentifier],[InstitutionName],[BrokerIdentifier],[BrokerFirstName],[BrokerLastName],[Channel],[loanGeneral_Id]) VALUES ('Cole Taylor Bank', '9960', 'jwright', 'John M', 'Wright', 'A0-Affiliate Standard', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] ([_StreetAddress],[_State],[_City],[_County],[_PostalCode],[loanGeneral_Id]) VALUES ('678 Ninth St.', 'MI', 'Ann Arbor', 'WASHTENAW', '481081111', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] ([AccountExecutiveName],[PipelineLoanStatusDescription],[loanGeneral_Id]) VALUES ('Ron Jacobs', 'Cancelled', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] ([_Type],[PropertyUsageType],[loanGeneral_Id]) VALUES ('Refinance', 'PrimaryResidence', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] ([ProductCode],[ProductDescription],[LockDate],[LockExpirationDate],[loanGeneral_Id]) VALUES ('FHA15FXD', 'FHA 15yr Fixed 203b', '20150710 10:34:09 AM', '20150803 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] ([_ReceivedDate],[_Status],[_SuspendedDate],[loanGeneral_Id]) VALUES ('20150708 10:34:09 AM', 'SUSPENDED','20150711 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] ([_Name],[loanGeneral_Id]) VALUES ('TotalObligationsIncomeRatio', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] ([ApplicationDate],[loanGeneral_Id]) VALUES ('20150702 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[DENIAL_LETTER] ([_CancelWithdrawnDate],[loanGeneral_Id]) VALUES ('20150711 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116'));

    }

    p 'starting inserts Esign Loan Events ======================='

    execute %Q{
      /* GFE Detail for loan num 1001111, loan general id 13660 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] ([loanGeneral_Id],[EventDate],[EventDescription]) VALUES (13660,'20150630 10:34:09 AM','DocMagic Initial Disclosure Request');
      /* GFE Detail for loan num 1001112, loan general id 13661 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] ([loanGeneral_Id],[EventDate],[EventDescription]) VALUES (13661,'20150701 10:34:09 AM','DocMagic Initial Disclosure Request');
      /* GFE Detail for loan num 1001113, loan general id 13662 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] ([loanGeneral_Id],[EventDate],[EventDescription]) VALUES (13662,'20150710 10:34:09 AM','DocMagic Initial Disclosure Request');
      /* GFE Detail for loan num 1001114, loan general id 13663 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] ([loanGeneral_Id],[EventDate],[EventDescription]) VALUES (13663,'20150629 10:34:09 AM','DocMagic Initial Disclosure Request');
      /* GFE Detail for loan num 1001115, loan general id 13664 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] ([loanGeneral_Id],[EventDate],[EventDescription]) VALUES (13664,'20150703 10:34:09 AM','DocMagic Initial Disclosure Request');
    }
  end

  def down
    return unless Rails.env.development?

    p 'starting deletes Esign Loan Events ======================='

    execute %Q{
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] WHERE [loanGeneral_Id] = 13660;
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] WHERE [loanGeneral_Id] = 13661;
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] WHERE [loanGeneral_Id] = 13662;
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] WHERE [loanGeneral_Id] = 13663;
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_EVENT] WHERE [loanGeneral_Id] = 13664;
    }

    p 'starting deletes Esign Loans ======================='

    execute %Q{
      /* Supporting data for loan 1001116 */
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[BORROWER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[DENIAL_LETTER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ctm_Loan] WHERE [Loan_Num] = '1001116';
    }

    execute %Q{
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001116';
    }
  end

end
