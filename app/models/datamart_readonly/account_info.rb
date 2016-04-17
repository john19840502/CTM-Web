class AccountInfo < DatabaseDatamartReadonly
  belongs_to :institution, primary_key: :institution_number, foreign_key: :institution_identifier
  belongs_to :originator, class_name: 'DatamartUser', primary_key: :username, foreign_key: :broker_identifier
  belongs_to :loan_general

  def self.non_retail
    where(channel: Channel.non_retail_ids)
  end

  def self.recent
    where{request_at > 1.year.ago}
  end

  def self.originator_names
    pluck(:broker_identifier).uniq
  end

  def self.institution_identifiers
    pluck(:institution_identifier).uniq
  end

  def self.recent_non_retail_originator_names
    self.non_retail.recent.originator_names
  end

  def self.recent_non_retail_institution_identifiers
    self.non_retail.recent.institution_identifiers
  end

  def self.sqlserver_create_view
    <<-eos
    SELECT
    		ACCOUNT_INFO_id	              AS id,
    		loanGeneral_Id	              AS loan_general_id,
    		LenderSiteIdentifier          AS lender_site_id,
            BrokerIdentifier              AS broker_identifier,
            BrokerEmailAddress	          AS broker_email_address,
            FinalSubmit	                  AS is_final_submit,
            RequestDateTime	              AS request_at,
            Channel	                      AS channel,
            InstitutionIdentifier         AS institution_identifier,
            InstitutionName	              AS institution_name,
            OriginatorEmployeeNumber      AS originator_employee_number,
            FileGenerationTrigger         AS file_generation_trigger,
            BrokerFirstName	              AS broker_first_name,
            BrokerLastName	              AS broker_last_name,
            User_Id	                      AS user_id,
            INSTITUTION_Id	              AS institution_id,
            FromConsumerWebsiteIndicator  AS is_from_consumer_website
    FROM    LENDER_LOAN_SERVICE.dbo.[ACCOUNT_INFO]
    eos
  end

  def branch_name
    institution.branch_name
  end

  def broker_name
    "#{broker_first_name} #{broker_last_name}"
  end
end
