class PopulateEsignLoans < ActiveRecord::Migration

  def up
    return unless Rails.env.development?

    p 'starting inserts Esign Loans ======================='

    execute %Q{
      /* TRID loan 1001111, denied */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] ([LenderDTDVersionID],[LenderRegistrationIdentifier],[loanStatus],[RequestDateTime],[User_Id]) VALUES ('3.0', '1001111', 20, '20150628 10:34:09 AM', 367);

      /* TRID loan 1001112, Withdrawn */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] ([LenderDTDVersionID],[LenderRegistrationIdentifier],[loanStatus],[RequestDateTime],[User_Id]) VALUES ('3.0', '1001112', 20, '20150630 10:34:09 AM', 367);

      /* TRID loan 1001113, cancelled */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] ([LenderDTDVersionID],[LenderRegistrationIdentifier],[loanStatus],[RequestDateTime],[User_Id]) VALUES ('3.0', '1001113', 20, '20150708 10:34:09 AM', 367);

      /* Pre-TRID loan 1001114, denied */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] ([LenderDTDVersionID],[LenderRegistrationIdentifier],[loanStatus],[RequestDateTime],[User_Id]) VALUES ('3.0', '1001114', 20, '20150627 10:34:09 AM', 367);
      
      /* TRID loan 1001115, suspended */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] ([LenderDTDVersionID],[LenderRegistrationIdentifier],[loanStatus],[RequestDateTime],[User_Id]) VALUES ('3.0', '1001115', 20, '20150701 10:34:09 AM', 367);
    }

    execute %Q{
      /* Supporting data for loan 1001111 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[BORROWER] ([BorrowerID],[_LastName],[_FirstName],[_EmailAddress],[_ApplicationSignedDate],[loanGeneral_Id]) VALUES ('BRW1', 'Borrower', 'J.', 'jborrower@fake.foo', '20150628 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] ([InstitutionIdentifier],[InstitutionName],[BrokerIdentifier],[BrokerFirstName],[BrokerLastName],[Channel],[loanGeneral_Id]) VALUES ('Cole Taylor Bank', '9960', 'jwright', 'John M', 'Wright', 'A0-Affiliate Standard', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] ([_StreetAddress],[_State],[_City],[_County],[_PostalCode],[loanGeneral_Id]) VALUES ('123 Fourth St.', 'MI', 'Ann Arbor', 'WASHTENAW', '481081111', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] ([AccountExecutiveName],[PipelineLoanStatusDescription],[loanGeneral_Id]) VALUES ('Ron Jacobs', 'Denied', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] ([_Type],[PropertyUsageType],[loanGeneral_Id]) VALUES ('Refinance', 'PrimaryResidence', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] ([ProductCode],[ProductDescription],[LockDate],[LockExpirationDate],[loanGeneral_Id]) VALUES ('FHA15FXD', 'FHA 15yr Fixed 203b', '20150703 10:34:09 AM', '20150803 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] ([_ReceivedDate],[_Status],[_DeniedDate],[loanGeneral_Id]) VALUES ('20150701 10:34:09 AM', 'DENIED','20150706 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] ([_Name],[loanGeneral_Id]) VALUES ('TotalObligationsIncomeRatio', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] ([ApplicationDate],[loanGeneral_Id]) VALUES ('20150628 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[DENIAL_LETTER] ([_DeniedDate],[loanGeneral_Id]) VALUES ('20150706 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111'));

      /* Supporting data for loan 1001112 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[BORROWER] ([BorrowerID],[_LastName],[_FirstName],[_EmailAddress],[_ApplicationSignedDate],[loanGeneral_Id]) VALUES ('BRW1', 'Borrower', 'L.', 'lborrower@fake.foo', '20150630 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] ([InstitutionIdentifier],[InstitutionName],[BrokerIdentifier],[BrokerFirstName],[BrokerLastName],[Channel],[loanGeneral_Id]) VALUES ('Cole Taylor Bank', '9960', 'jwright', 'John M', 'Wright', 'A0-Affiliate Standard', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] ([_StreetAddress],[_State],[_City],[_County],[_PostalCode],[loanGeneral_Id]) VALUES ('234 Fifth St.', 'MI', 'Ann Arbor', 'WASHTENAW', '481081111', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] ([AccountExecutiveName],[PipelineLoanStatusDescription],[loanGeneral_Id]) VALUES ('Ron Jacobs', 'Withdrawn', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] ([_Type],[PropertyUsageType],[loanGeneral_Id]) VALUES ('Refinance', 'PrimaryResidence', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] ([ProductCode],[ProductDescription],[LockDate],[LockExpirationDate],[loanGeneral_Id]) VALUES ('FHA15FXD', 'FHA 15yr Fixed 203b', '20150703 10:34:09 AM', '20150803 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] ([_ReceivedDate],[_Status],[_SuspendedDate],[loanGeneral_Id]) VALUES ('20150702 10:34:09 AM', 'SUSPENDED','20150708 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] ([_Name],[loanGeneral_Id]) VALUES ('TotalObligationsIncomeRatio', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] ([ApplicationDate],[loanGeneral_Id]) VALUES ('20150628 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[DENIAL_LETTER] ([_CancelWithdrawnDate],[loanGeneral_Id]) VALUES ('20150708 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112'));

      /* Supporting data for loan 1001113 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[BORROWER] ([BorrowerID],[_LastName],[_FirstName],[_EmailAddress],[_ApplicationSignedDate],[loanGeneral_Id]) VALUES ('BRW1', 'Borrower', 'S.', 'sborrower@fake.foo', '20150708 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] ([InstitutionIdentifier],[InstitutionName],[BrokerIdentifier],[BrokerFirstName],[BrokerLastName],[Channel],[loanGeneral_Id]) VALUES ('Cole Taylor Bank', '9960', 'jwright', 'John M', 'Wright', 'A0-Affiliate Standard', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] ([_StreetAddress],[_State],[_City],[_County],[_PostalCode],[loanGeneral_Id]) VALUES ('345 Sixth St.', 'MI', 'Ann Arbor', 'WASHTENAW', '481081111', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] ([AccountExecutiveName],[PipelineLoanStatusDescription],[loanGeneral_Id]) VALUES ('Ron Jacobs', 'Cancelled', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] ([_Type],[PropertyUsageType],[loanGeneral_Id]) VALUES ('Refinance', 'PrimaryResidence', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] ([ProductCode],[ProductDescription],[LockDate],[LockExpirationDate],[loanGeneral_Id]) VALUES ('FHA15FXD', 'FHA 15yr Fixed 203b', '20150710 10:34:09 AM', '20150803 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] ([_ReceivedDate],[_Status],[_SuspendedDate],[loanGeneral_Id]) VALUES ('20150708 10:34:09 AM', 'SUSPENDED','20150711 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] ([_Name],[loanGeneral_Id]) VALUES ('TotalObligationsIncomeRatio', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] ([ApplicationDate],[loanGeneral_Id]) VALUES ('20150708 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[DENIAL_LETTER] ([_CancelWithdrawnDate],[loanGeneral_Id]) VALUES ('20150711 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113'));

      /* Supporting data for loan 1001114 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[BORROWER] ([BorrowerID],[_LastName],[_FirstName],[_EmailAddress],[_ApplicationSignedDate],[loanGeneral_Id]) VALUES ('BRW1', 'Borrower', 'T.', 'tborrower@fake.foo', '20150627 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] ([InstitutionIdentifier],[InstitutionName],[BrokerIdentifier],[BrokerFirstName],[BrokerLastName],[Channel],[loanGeneral_Id]) VALUES ('Cole Taylor Bank', '9960', 'jwright', 'John M', 'Wright', 'A0-Affiliate Standard', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] ([_StreetAddress],[_State],[_City],[_County],[_PostalCode],[loanGeneral_Id]) VALUES ('456 Seventh St.', 'MI', 'Ann Arbor', 'WASHTENAW', '481081111', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] ([AccountExecutiveName],[PipelineLoanStatusDescription],[loanGeneral_Id]) VALUES ('Ron Jacobs', 'Denied', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] ([_Type],[PropertyUsageType],[loanGeneral_Id]) VALUES ('Refinance', 'PrimaryResidence', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] ([ProductCode],[ProductDescription],[LockDate],[LockExpirationDate],[loanGeneral_Id]) VALUES ('FHA15FXD', 'FHA 15yr Fixed 203b', '20150630 10:34:09 AM', '20150803 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] ([_ReceivedDate],[_Status],[_DeniedDate],[loanGeneral_Id]) VALUES ('20150628 10:34:09 AM', 'DENIED','20150701 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] ([_Name],[loanGeneral_Id]) VALUES ('TotalObligationsIncomeRatio', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] ([ApplicationDate],[loanGeneral_Id]) VALUES ('20150627 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[DENIAL_LETTER] ([_DeniedDate],[loanGeneral_Id]) VALUES ('20150701 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114'));

      /* Supporting data for loan 1001115 */
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[BORROWER] ([BorrowerID],[_LastName],[_FirstName],[_EmailAddress],[_ApplicationSignedDate],[loanGeneral_Id]) VALUES ('BRW1', 'Borrower', 'K.', 'kborrower@fake.foo', '20150701 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] ([InstitutionIdentifier],[InstitutionName],[BrokerIdentifier],[BrokerFirstName],[BrokerLastName],[Channel],[loanGeneral_Id]) VALUES ('Cole Taylor Bank', '9960', 'jwright', 'John M', 'Wright', 'A0-Affiliate Standard', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] ([_StreetAddress],[_State],[_City],[_County],[_PostalCode],[loanGeneral_Id]) VALUES ('567 Eighth St.', 'MI', 'Ann Arbor', 'WASHTENAW', '481081111', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] ([AccountExecutiveName],[PipelineLoanStatusDescription],[loanGeneral_Id]) VALUES ('Ron Jacobs', 'Suspended', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] ([_Type],[PropertyUsageType],[loanGeneral_Id]) VALUES ('Refinance', 'PrimaryResidence', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] ([ProductCode],[ProductDescription],[LockDate],[LockExpirationDate],[loanGeneral_Id]) VALUES ('FHA15FXD', 'FHA 15yr Fixed 203b', '20150710 10:34:09 AM', '20150712 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] ([_ReceivedDate],[_Status],[_SuspendedDate],[loanGeneral_Id]) VALUES ('20150702 10:34:09 AM', 'SUSPENDED','20150717 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] ([_Name],[loanGeneral_Id]) VALUES ('TotalObligationsIncomeRatio', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] ([loanGeneral_Id]) VALUES ((SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
      INSERT INTO [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] ([ApplicationDate],[loanGeneral_Id]) VALUES ('20150701 10:34:09 AM', (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115'));
    }
  end

  def down
    return unless Rails.env.development?

    p 'starting deletes Esign Loans ======================='

    execute %Q{
      /* Supporting data for loan 1001111 */
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[BORROWER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[DENIAL_LETTER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ctm_Loan] WHERE [Loan_Num] = '1001111';

      /* Supporting data for loan 1001112 */
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[BORROWER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[DENIAL_LETTER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ctm_Loan] WHERE [Loan_Num] = '1001112';

      /* Supporting data for loan 1001113 */
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[BORROWER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[DENIAL_LETTER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ctm_Loan] WHERE [Loan_Num] = '1001113';

      /* Supporting data for loan 1001114 */
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[BORROWER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[DENIAL_LETTER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ctm_Loan] WHERE [Loan_Num] = '1001114';

      /* Supporting data for loan 1001115 */
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[BORROWER] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ACCOUNT_INFO] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[PROPERTY] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ADDITIONAL_LOAN_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_PURPOSE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOCK_PRICE] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[UNDERWRITING_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[CALCULATION] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[INVESTOR_LOCK] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_DETAILS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_FEATURES] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[MORTGAGE_TERMS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSACTION_DETAIL] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[COMPLIANCE_ALERTS] WHERE [loanGeneral_Id] = (SELECT [loanGeneral_Id] FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115');
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[ctm_Loan] WHERE [Loan_Num] = '1001115';
    }

    execute %Q{
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001111';
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001112';
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001113';
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001114';
      DELETE FROM [LENDER_LOAN_SERVICE].[dbo].[LOAN_GENERAL] WHERE [LenderRegistrationIdentifier] = '1001115';
    }
  end

end
