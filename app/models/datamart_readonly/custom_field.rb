class CustomField < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT     CUSTOM_FIELD_id AS id,
                 LoanGeneral_Id AS loan_general_id,
                 FormUniqueName AS form_unique_name,
                 FormLabelDescription AS form_label_description,
                 InstanceSequence AS instance_sequence,
                 AttributeTypeUniqueName AS attribute_type_unique_name,
                 AttributeTypeLabelDescription AS attribute_type_label_description,
                 AttributeUniqueName AS attribute_unique_name,
                 AttributeLabelDescription AS attribute_label_description,
                 AttributeValue AS attribute_value
      FROM       LENDER_LOAN_SERVICE.dbo.[CUSTOM_FIELD]
    eos
  end

  scope :intent_to_proceed, ->(end_date) {where("form_unique_name = 'Registration Tracking' AND attribute_unique_name = 'RegTrackingITPDate' AND attribute_value IS NOT NULL AND CONVERT(DATETIME,attribute_value) <= CONVERT(DATETIME,?)", end_date.strftime("%m/%d/%Y"))}

  def self.find_attributes(unique_name, description, value)
    where(attribute_unique_name: unique_name, attribute_label_description: description, attribute_value: value)
  end

  def self.is_preapproval?
    self.find_attributes("UWSubmissionPreapproval", "Is this a Pre-Approval (TBD)?", "Y").any?
  end

  def self.in_uw_station?
    where(form_unique_name: 'Submit File to UW', attribute_unique_name: 'UWSubmissionRcvd').where{ attribute_value != nil }.any?
  end

  def self.not_in_uw_station?
    where(form_unique_name: 'Submit File to UW', attribute_unique_name: 'UWSubmissionRcvd', attribute_value: nil).any?
  end

  def self.has_pers_id?
    where(attribute_unique_name: 'PERS ID').where{attribute_value != nil}.any?
  end

  def self.in_pers_list?
    where(attribute_unique_name: 'Pers list').pluck(:attribute_value).first
  end

  def self.intent_to_proceed_date_string
    where(form_unique_name: "Registration Tracking", attribute_unique_name: "RegTrackingITPDate").first.try!(:attribute_value)
  end

  def self.initial_disclosure_retail
    where(form_unique_name: "Retail Initial Disclosure Request", attribute_unique_name: "RequestDisclosure").order(:instance_sequence)
  end

  def self.initial_disclosure_wholesale
    where(form_unique_name: "Wholesale Initial Disclosure Request", attribute_unique_name: "Ready to Request Disclosure").order(:instance_sequence)
  end

  def self.lender_paid_mi?
    where(form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionCompType", attribute_value: "Lender Paid").any?
  end
end
