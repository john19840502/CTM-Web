# [_AgeAtApplicationYears] [smallint] NULL,
# [_ApplicationSignedDate] [smalldatetime] NULL,
# [_BirthDate] [smalldatetime] NULL,
# [_CellTelephoneNumber] [varchar](50) NULL,
# [_FaxTelephoneNumber] [varchar](50) NULL,
# [_ITIN] [varchar](9) NULL,
# [_PrintPositionType] [varchar](20) NULL,
# [CreditReportIdentifier] [varchar](50) NULL,
# [DependentCount] [tinyint] NULL,
# [JointAssetBorrowerID] [varchar](50) NULL,
# [JointAssetLiabilityReportingType] [varchar](10) NULL,
# [MaritalStatusType] [varchar](10) NULL,
# [SchoolingYears] [tinyint] NULL,

class Borrower < DatabaseDatamartReadonly
  belongs_to :loan
  belongs_to :loan_general
  has_many :employments

  acts_as_list :scope => :loan

  def self.sqlserver_create_view
    <<-eos
      SELECT      lg.LenderRegistrationIdentifier + RIGHT('0000' + REPLACE(borr.BorrowerID, 'BRW', ''), 3)  AS id,
                  lg.LenderRegistrationIdentifier                                                           AS loan_id, 
                  borr.loanGeneral_Id                                                                       AS loan_general_id,
                  REPLACE(borr.BorrowerID, 'BRW', '')                                                       AS position,
                  borr.BorrowerID                                                                           AS borrower_id,
                  borr._FirstName                                                                           AS first_name,
                  borr._MiddleName                                                                          AS middle_name,
                  borr._LastName                                                                            AS last_name,
                  borr._NameSuffix                                                                          AS suffix,
                  borr.CreditScore                                                                          AS credit_score,
                  borr._HomeTelephoneNumber                                                                 AS home_tele_num,
                  borr._EmailAddress                                                                        AS email,
                  borr._SSN                                                                                 AS ssn,
                  borr.[EquifaxCreditScore]                                                                 AS equifax_credit_score,
                  borr.[ExperianCreditScore]                                                                AS experian_credit_score,
                  borr.[TransUnionCreditScore]                                                              AS trans_union_credit_score,
                  borr._ApplicationSignedDate                                                               AS application_signed_date
      FROM         LENDER_LOAN_SERVICE.dbo.LOAN_GENERAL AS lg INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.BORROWER AS borr ON lg.loanGeneral_Id = borr.loanGeneral_Id
    eos
  end

  def self.primary
    order(:borrower_id).uniq(&:borrower_id).first
  end

  def dup_ssn?
    Borrower.where(ssn: ssn).count > 1
  end

  def first_last_name
    [first_name, last_name].join(' ')
  end

  def full_name
    [first_name, middle_name, last_name, suffix].map(&:presence).compact.join(' ')
  end

  def last_name_with_suffix
    [last_name, suffix].join(', ')
  end

  def full_name_sort
    [last_name_with_suffix, first_name, middle_name].join(' ')
  end

  def full_name_nbsp
    full_name.gsub(' ','&nbsp;')
  end

  def full_name_with_middle_initial
    [first_name, middle_initial, last_name, suffix].join(' ')
  end

  def middle_initial
    middle_name.slice(0) + '.' unless middle_name.nil?
  end

  def income_total
    employments.inject(0.0){|sub, e| sub += e.monthly_income.to_f}
  end

  def ssn_formatted
    ssn.to_s.strip.sub(/(\d{3})(\d{2})(\d{4})/, "\\1-\\2-\\3")
  end

  def citizen?
    if loan_general && loan_general.declarations.present?
      return 'N/A' if loan_general.declarations.map{|m| m if m.borrower_id.eql?("BRW#{position}")}.compact.count.eql?(0)
      loan_general.declarations.map{|m| m if m.citizenship_residency_type.eql?('USCitizen') and m.borrower_id.eql?("BRW#{position}")}.compact.count > 0 ? 'Yes' : 'No'
    else
      data_not_present
    end
  end

  def permanent_alien?
    if loan_general && loan_general.declarations.present?
      status = loan_general.declarations.map{|m| m.citizenship_residency_type if m.borrower_id.eql?("BRW#{position}")}.compact.join

      case status
        when 'PermanentResidentAlien' then 'Yes'
        when 'NonPermanentResidentAlien' then 'No'
        when 'USCitizen' then ''
        else 'N/A'
      end
    else
      data_not_present
    end
  end

  def intent_to_occupy?
    if loan_general && loan_general.declarations.present?
      return 'N/A' if loan_general.try(:declarations) && loan_general.declarations.map{|m| m if m.borrower_id.eql?("BRW#{position}")}.compact.count.eql?(0)
      loan_general.declarations.map{|d| d if (d.intent_to_occupy_type.eql?('Yes') and d.borrower_id.eql?("BRW#{position}"))}.compact.count > 0 ? 'Yes' : 'No'
    else
      data_not_present
    end
  end

  def  occupying?
    residences.current.any? {|r| r.borrower_residency_basis_type.try(:downcase) == "own"} 
  end

  def middle_credit_score
    scores = [equifax_credit_score, experian_credit_score, trans_union_credit_score].map(&:presence).compact.sort
    case scores.size
    when 3; scores[1]
    when 2; scores[0]
    when 1; scores[0]
    end
  end

private
  
  def data_not_present
    if loan_general
      'N/A'
    else
      'Data Error'
    end    
  end
end
