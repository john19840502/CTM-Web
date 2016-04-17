# In CompassLoanDetails, the data elements for each borrower are put in as
# Brw1FName
# Brw2FName
# The purpose of this class is to simplify the calling of these elements
# by making it so that each borrower can find its own element from compass.
class Smds::UlddBorrower
  def initialize(loan, index)
    self.loan = loan
    self.index = index
  end

  def master_borrower
    loan.master_borrower(index)
  end

  def compass_loan_detail
    loan.compass_loan_detail
  end

  def loan_general
    loan.loan_general
  end

  def address; mailing_address_section loan.MailingStreetAddress, 100; end
  def cityname; mailing_address_section loan.MailingCity, 50; end
  def postal_code; mailing_address_section loan.MailingPostalCode, 9; end
  def state_code; mailing_address_section loan.MailingState, 2; end

  def address_type
    return '' unless has_separate_billing_address?
    'Mailing'
  end

  def country_code
    return '' unless has_separate_billing_address?
    return '' unless loan.USAddress == 'Y'
    'US'
  end

  def classification_type
    return 'Primary' if primary_borrower?
    'Secondary'
  end

  def address_same_as_property?
    loan.DifferentPropertyAddress != 'Y'
  end

  def default_credit_score_source
    # borrowers 3 and 4 don't have a credit score source field in CompassLoanDetails because it pulls from ALL_PROPERTIES_LOAN_TYPES, which doesn't have a value except for primary and coborrower
    return '' if index == 3 || index == 4

    fetch('CreditScoreSource')
  end

  def credit_score_source
    source = middle_credit_score_source || default_credit_score_source

    case source
    when /experian/i
      'Experian'
    when /equifax/i
      'Equifax'
    when /transunion/i
      'TransUnion'
    else
      ''
    end
  end

  def credit_score_indicator
    credit_score_source.present?
  end

  delegate :first_name,
           :last_name,
           :suffix,
           :borrower_id,
           :age_at_application,
           :middle_credit_score,
           :middle_credit_score_source,
           :races,
           :ssn,
           to: :master_borrower, allow_nil: true
  delegate :race_entries,
           to: :compass_loan_detail, allow_nil: true
  delegate :loan_forceclosure_indicator,
           to: :loan_general, allow_nil: true

  def middle_name
    extract master_borrower.middle_name, 1
  end

  def default_credit_score
    master_borrower.credit_score
  end

  def birth_date
    format_date master_borrower.birth_date
  end

  def qualifying_income
    extract master_borrower.qualifying_income.to_i.to_s, 9
  end

  def credit_score
    format_num (middle_credit_score || default_credit_score)
  end

  def borrower_age_at_application
    age_in_years_on loan.ApplicationReceivedDate, master_borrower.birth_date
  end

  def age_in_years_on(date, birthday)
    return '' unless date.present? && birthday.present?
    date = Date.parse(date) unless date.respond_to?(:month)
    birthday = Date.parse(date) unless birthday.respond_to?(:month)
    adjustment = (date.month > birthday.month || (date.month == birthday.month && date.day >= birthday.day)) ? 0 : 1
    date.year - birthday.year - adjustment
  end

  def bankruptcy_indicator
    primary_borrower? && loan.Bankruptcy == 'Y'
  end

  def first_time_homebuyer_indicator
    return '' unless loan.LoanPurposeType == 'Purchase'
    return '' unless loan.PropertyUsageType == 'PrimaryResidence'
    loan.FirstTimeHomebuyer == 'Y'
  end

  def borrower_first_time_homebuyer_indicator
    return '' unless loan.LoanPurposeType == 'Purchase'
    return '' unless loan.PropertyUsageType == 'PrimaryResidence'
    loan["Brw#{index}FirstTimeHomebuyer"] == 'Y'
  end

  def citizenship_type
    restrict_value_to master_borrower.citizenship_type,
      'NonPermanentResidentAlien', 'PermanentResidentAlien', 'USCitizen'
  end

  def foreclosure_indicator
    loan_forceclosure_indicator(index)
  end

  def self_employment_indicator
    loan.SelfEmpFlg == 'Y'
  end

  def gender(current_index)
    restrict_value_to compass_loan_detail.gender_type(current_index) , 'Male', 'Female', 'InformationNotProvidedUnknown', 'NotApplicable'
  end

  def ethnicity
    restrict_value_to master_borrower.hmda_ethnicity_type, 'HispanicOrLatino', 'NotHispanicOrLatino',
            'InformationNotProvidedByApplicantInMailInternetOrTelephoneApplication',
            'NotApplicable'
  end

  def taxpayer_identifier
    extract ssn, 9
  end

  def credit_report_identifier
    master_borrower.credit_reports.
      select{ |cr| cr.engine_code == "fannie" && cr.order_status == "Success"}.
      last.try!(:credit_report_identifier)
  end

  private
  attr_accessor :loan, :index

  include Smds::DataCleanupMethods

  def primary_borrower?
    index == 1
  end

  def mailing_address_section(source, length)
    return '' unless has_separate_billing_address?
    extract source, length
  end

  def fetch(method_name)
    loan.public_send("Brw#{index}#{method_name}")
  end

  def has_separate_billing_address?
    loan.DifferentPropertyAddress == 'Y'
  end

  RACES = [ 'AmericanIndianOrAlaskaNative', 'Asian',
          'BlackOrAfricanAmerican', 'NativeHawaiianOrOtherPacificIslander', 'White',
          'InformationNotProvidedByApplicantInMailInternetOrTelephoneApplication',
          'NotApplicable' ]


end
