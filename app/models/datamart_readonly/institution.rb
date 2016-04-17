# This is the Avista information for an institution, usually a branch
class Institution < DatabaseDatamartReadonly
  has_many :loans, class_name: 'Master::Loan', primary_key: :institution_number, foreign_key: :institution_identifier

  has_many :datamart_user_profiles, foreign_key: :institution_id

  has_many :multi_institutions, foreign_key: :institution_id
  has_many :employees, class_name: 'BranchEmployee', through: :multi_institutions

  has_one :area_manager_region, primary_key: :ae_user_id, foreign_key: :datamart_user_id
  has_one :region, through: :area_manager_region

  has_many :comp_tiers, primary_key: :institution_number, foreign_key: :institution_number

  has_many :branch_compensations
  has_many :account_infos, primary_key: :institution_number, foreign_key: :institution_identifier

  has_one :area_manager, class_name: 'DatamartUser', primary_key: :ae_user_id, foreign_key: :id

  scope :retail, ->{ where(channel: Channel.retail.identifier) }
  scope :all_retail, ->{ where {channel.in [Channel.retail.identifier,Channel.consumer_direct.identifier]} }
  scope :wholesale, ->{ where(channel: Channel.wholesale.identifier) }
  scope :reimbursement, ->{ where(channel: Channel.reimbursement.identifier) }
  scope :by_region, lambda { |region| {:joins => :region, :conditions => { :region => {:name => region}}}}

  scope :active, ->{ where(is_active: true) }

  def self.recent_expiring_originators
    recent_numbers = AccountInfo.recent_non_retail_institution_identifiers
    expiring_institution_ids = LicensedState.expiring_institution_ids
    self.where{id.in expiring_institution_ids}.where{institution_number.in recent_numbers}
  end

  def self.sqlserver_create_view
    <<-eos
      SELECT
          INSTITUTION_Id                          AS id,
          ActivatedDate                           AS activated_date,
          Address                                 AS address,
          AEUserId                                AS ae_user_id,
          Channel                                 AS channel,
          City                                    AS city,
          CloseInInstitutionName                  AS close_in_institution_name,
          CompanyCode                             AS company_code,
          ConsumerSiteAvailableIndicator          AS consumer_site_available_indicator,
          ContactEmail                            AS contact_email,
          ContactPersonFirstName                  AS contact_person_first_name,
          ContactPersonLastName                   AS contact_person_last_name,
          ContractProcessing                      AS contract_processing,
          DelegatedUnderwriting                   AS delegated_underwriting,
          DelegatedUnderwritingGroupName          AS delegated_underwriting_group_name,
          DocumentationPreparationByInstitution   AS documentation_preparation_by_institution,
          DocumentationPreparationByLender        AS documentation_preparation_by_lender,
          FannieBranchCode                        AS fannie_branch_code,
          Fax                                     AS fax,
          FederalTaxIdentifier                    AS federal_tax_identifier,
          FHALenderIdentifier                     AS fha_lender_identifier,
          FHALenderIdentifierExpirationDate       AS fha_lender_identifier_expiration_date,
          FHASponsorIdentifier                    AS fha_sponsor_identifier,
          FNMAOriginatorCompanyIdentifier         AS institution_nmls_id,
          GUID                                    AS guid,
          InstitutionLegalName                    AS institution_legal_name,
          InstitutionNumber                       AS institution_number,
          InstitutionTypeDescription              AS institution_type_description,
          IsActive                                AS is_active,
          isOnWatchList                           AS is_on_watch_list,
          LineOfCredit                            AS line_of_credit,
          LPThirdPartyOriginatorIdentifier        AS lp_third_party_originator_identifier,
          Name                                    AS name,
          NMLSExemptIndicator                     AS nmls_exempt_indicator,
          Phone                                   AS phone,
          Region                                  AS region,
          State                                   AS state,
          TableFunded                             AS table_funded,
          TeamId                                  AS team_id,
          TeamName                                AS team_name,
          TerminatedDate                          AS terminated_date,
          TerminatedReason                        AS terminated_reason,
          TermsOfBusiness                         AS terms_of_business,
          VALenderIdentifier                      AS va_lender_identifier,
          VALenderIdentifierExpirationDate        AS va_lender_identifier_expiration_date,
          VASponsorIdentifier                     AS va_sponsor_identifier,
          WarehouseFunded                         AS warehouse_funded,
          WatchListReason                         AS watch_list_reason,
          Zip                                     AS zip
      FROM       LENDER_LOAN_SERVICE.dbo.[INSTITUTION]
    eos
  end

  #active_scaffold highest priority default property, otherwise it picks 'name' for the default
  def to_label
    branch_name
  end

  # TODO: if there will be more than one branch in the same city, we'll need to figure some token of differentiation here.
  def branch_name
    if name.in?(['Cole Taylor Bank', 'MB Financial Bank, N.A.'])
      sfx = Channel.consumer_direct.identifier.eql?(channel) ? ' CD' : ''
      "MB #{city}#{sfx}"
    else
      name
    end
  end

  def self.active_at(date)
    where { ( activated_date <= date ) & ( (terminated_date == nil) | (terminated_date > date) ) }
  end

  # Insitutions not assignde to a region, should be 719
  def self.orphaned_institutions(channel)
    inst = []
    Region.all.each do |r|
      inst += self.where(channel: channel).by_region(r.name).map(&:institution_number)
    end
    remaining = (self.where(channel: channel).map(&:institution_number) - inst)
    self.where(channel: channel, institution_number: remaining)
  end

  def last_loan_date
    account_infos.maximum(:request_at)
  end

  def branch_manager
    manager_profile = DatamartUserProfile.where{ (institution_id == id) & (effective_date <= Date.today) & (title == 'Branch Manager') }.last 
    return nil if manager_profile.nil?
    manager_profile.branch_employee
  end
end
