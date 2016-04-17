class ManualFactType < ActiveRecord::Base
  belongs_to :loan, foreign_key: :loan_num, primary_key: :loan_num

  validates :loan_num, :name, :value, presence: true

  validates :name, inclusion: {in: [
    'right_to_delay', 'texas_only', 'Existing Survey Indicator','Type of Veteran', 
    'VA Homebuyer Usage Indicator', 'E Consent Indicator', 'Second Closer Name',
    'Premium Pricing Percent', 'Premium Pricing Amount', 'Discount Percent', 'Discount Amount',
    'Borrower Paid Percent', 'Borrower Paid Amount', 'Seller Credit Amount', 'cash_to_close',
    'Earnest Money Amount', 'Condo Project Name', 'Payoff Amount'
  ]}

  attr_accessible :name

  def self.collect_facttype facttype_name
    find_by(name: facttype_name)
  end

  def as_json(opts={})
    super(opts.merge methods: [:user_name])
  end

  def user_name
    User.find(self.created_by).try(:display_name) rescue nil
  end

  def self.save_fact_type loan_num, name, value
    stuff = {loan_num: loan_num, name: name}
    mft = ManualFactType.find_by(stuff) || ManualFactType.new(stuff, without_protection: true)
    #TODO: check value against options?
    mft.value = value
    mft.created_by = current_user.uuid
    mft.save!
    mft
  end

  def self.build_form_definitions loan, names
    names.map do |name| 
      build_form_definition(loan, name)
    end
  end

  def self.build_form_definition loan, name
    fd = @@form_definition_templates.find {|ft| ft.name == name }
    { field_name: name,
      field_label_text: fd.label,
      options: fd.options,
      value: loan.collect_facttype(name).try(:value) || fd.default,
    }
  end

  FormDefinition = Struct.new(:name, :label, :options, :default)

  @@form_definition_templates = [
    FormDefinition.new("Existing Survey Indicator",
                       "Are we using an existing survey?", [ "Yes", "No"], "No"),
    FormDefinition.new("Type of Veteran",
                       "Veteran Type", [ "Regular Military", "Reserves"]),
    FormDefinition.new("VA Homebuyer Usage Indicator",
                       "Use Type", [ "Subsequent Usage", "First Time Usage"]),
    FormDefinition.new("E Consent Indicator",
                       "Consent to Receive Electronically", [ "Yes", "No"], "No"),
  ]

end
