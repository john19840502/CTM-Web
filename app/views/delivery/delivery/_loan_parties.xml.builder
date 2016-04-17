builder.PARTIES do
  if loan.AppraiserLicenseIdentifier.present?
    builder.PARTY do
      builder.ROLES do
        builder.ROLE do
          builder.APPRAISER do
            builder.APPRAISER_LICENSE do
              builder.AppraiserLicenseIdentifier loan.AppraiserLicenseIdentifier
            end
          end
          builder.ROLE_DETAIL do
            builder.PartyRoleType 'Appraiser'
          end
        end
      end
    end
  end
  if loan.AppraiserSupervisorLicenseIdentifier.present?
    builder.PARTY do
      builder.ROLES do
        builder.ROLE do
          builder.APPRAISER_SUPERVISOR do
            builder.APPRAISER_LICENSE do
              builder.AppraiserLicenseIdentifier loan.AppraiserSupervisorLicenseIdentifier
            end
          end
          builder.ROLE_DETAIL do
            builder.tag! "PartyRoleType", 'AppraiserSupervisor'
          end
        end
      end
    end
  end
  loan.borrowers.each_with_index do |borrower, ix|
    builder.PARTY do
      builder.INDIVIDUAL do
        builder.NAME do
          builder.FirstName borrower.first_name
          builder.LastName borrower.last_name
          builder.MiddleName borrower.middle_name
          builder.SuffixName borrower.suffix
        end
      end
      builder.ADDRESSES do
        builder.ADDRESS do
          builder.AddressLineText borrower.address
          builder.AddressType borrower.address_type
          builder.CityName borrower.cityname
          builder.CountryCode borrower.country_code
          builder.PostalCode borrower.postal_code
          builder.StateCode borrower.state_code
        end
      end
      builder.ROLES do
        builder.ROLE do
          builder.BORROWER do
            builder.BORROWER_DETAIL do
              builder.BorrowerAgeAtApplicationYearsCount borrower.borrower_age_at_application
              builder.BorrowerBirthDate borrower.birth_date
              builder.BorrowerClassificationType borrower.classification_type
              builder.BorrowerMailToAddressSameAsPropertyIndicator borrower.address_same_as_property?
              builder.BorrowerQualifyingIncomeAmount borrower.qualifying_income
            end
            if loan.home_ready?
              builder.COUNSELING_CONFIRMATION do
                builder.CounselingConfirmationType 'HUDApprovedCounselingAgency'
                builder.CounselingFormatType 'HomeStudy'
              end
            end
            builder.CREDIT_SCORES do
              builder.CREDIT_SCORE do
                builder.CREDIT_SCORE_DETAIL do
                  if loan.delivery_type == "FHLMC"
                    builder.CreditReportIdentifier loan.credit_report_identifier if borrower.credit_score_source == 'Merged Data'
                  else
                    builder.CreditReportIdentifier borrower.credit_report_identifier
                  end
                  builder.CreditRepositorySourceIndicator borrower.credit_score_indicator
                  builder.CreditRepositorySourceType loan.borrower_credit_score_source(ix) || borrower.credit_score_source
                  builder.CreditScoreValue loan.borrower_credit_score(ix)
                end
              end
            end
            builder.DECLARATION do
              builder.DECLARATION_DETAIL do
                builder.BankruptcyIndicator borrower.bankruptcy_indicator
                builder.BorrowerFirstTimeHomebuyerIndicator borrower.borrower_first_time_homebuyer_indicator
                builder.CitizenshipResidencyType borrower.citizenship_type
                builder.LoanForeclosureOrJudgmentIndicator borrower.foreclosure_indicator
              end
            end
            builder.EMPLOYERS do
              builder.EMPLOYER do
                builder.EMPLOYMENT do
                  builder.EmploymentBorrowerSelfEmployedIndicator borrower.self_employment_indicator
                end
              end
            end
            builder.GOVERNMENT_MONITORING do
              builder.GOVERNMENT_MONITORING_DETAIL do
                builder.GenderType borrower.gender(ix)
                builder.HMDAEthnicityType borrower.ethnicity
              end
              builder.HMDA_RACES do
                borrower.race_entries(ix).each do |race|
                  builder.HMDA_RACE do
                    builder.HMDARaceType race
                  end
                end
              end
            end
          end
          builder.ROLE_DETAIL do
            builder.tag! "PartyRoleType", "Borrower"
          end
        end
      end
      builder.TAXPAYER_IDENTIFIERS do
        builder.TAXPAYER_IDENTIFIER do
          builder.TaxpayerIdentifierType 'SocialSecurityNumber'
          builder.TaxpayerIdentifierValue borrower.taxpayer_identifier
        end
      end
    end
  end
  if loan.document_custodian.present?
    builder.PARTY do
      builder.ROLES do
        builder.PARTY_ROLE_IDENTIFIERS do
          builder.PARTY_ROLE_IDENTIFIER do
            builder.PartyRoleIdentifier loan.document_custodian
          end
        end
        builder.ROLE do
          builder.ROLE_DETAIL do
            builder.PartyRoleType 'DocumentCustodian'
          end
        end
      end
    end
  end
  if loan.LoanOriginationCompanyIdentifier.present?
    builder.PARTY do
      builder.ROLES do
        builder.PARTY_ROLE_IDENTIFIERS do
          builder.PARTY_ROLE_IDENTIFIER do
            builder.PartyRoleIdentifier loan.LoanOriginationCompanyIdentifier
          end
        end
        builder.ROLE do
          builder.ROLE_DETAIL do
            builder.tag! "PartyRoleType", 'LoanOriginationCompany'
          end
        end
      end
    end
  end
  if loan.LoanOriginatorIdentifier.present?
    builder.PARTY do
      builder.ROLES do
        builder.PARTY_ROLE_IDENTIFIERS do
          builder.PARTY_ROLE_IDENTIFIER do
            builder.PartyRoleIdentifier loan.LoanOriginatorIdentifier
          end
        end
        builder.ROLE do
          builder.LOAN_ORIGINATOR do
            builder.LoanOriginatorType loan.LoanOriginatorType
          end
          builder.ROLE_DETAIL do
            builder.PartyRoleType 'LoanOriginator'
          end
        end
      end
    end
  end
  builder.PARTY do
    builder.ROLES do
      builder.PARTY_ROLE_IDENTIFIERS do
        builder.PARTY_ROLE_IDENTIFIER do
          builder.tag! "PartyRoleIdentifier", '272190003'
        end
      end
      builder.ROLE do
        builder.ROLE_DETAIL do
          builder.tag! "PartyRoleType", 'LoanSeller'
        end
      end
    end
  end
  builder.PARTY do
    builder.LEGAL_ENTITY do
      builder.LEGAL_ENTITY_DETAIL do
        builder.FullName loan.FullName
      end
    end
    builder.ROLES do
      builder.ROLE do
        builder.ROLE_DETAIL do
          builder.PartyRoleType "NotePayTo"
        end
      end
    end
  end
  builder.PARTY do
    builder.ROLES do
      builder.PARTY_ROLE_IDENTIFIERS do
        builder.PARTY_ROLE_IDENTIFIER do
          builder.PartyRoleIdentifier '002003402'
        end
      end
      builder.ROLE do
        builder.ROLE_DETAIL do
          builder.PartyRoleType 'Payee'
        end
      end
    end
  end
  builder.PARTY do
    builder.ROLES do
      builder.PARTY_ROLE_IDENTIFIERS do
        builder.PARTY_ROLE_IDENTIFIER do
          builder.PartyRoleIdentifier loan.servicer_number
        end
      end
      builder.ROLE do
        builder.ROLE_DETAIL do
          builder.PartyRoleType 'Servicer'
        end
      end
    end
  end
end
