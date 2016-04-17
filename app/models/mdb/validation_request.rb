module Mdb
  class ValidationRequest
    include Mongoid::Document

    field :validated_by, type: String
    field :validated_by_id, type: Integer
    field :date, type: DateTime
    field :initial_decision, type: DateTime
    field :final_approval, type: DateTime
    field :total_rules_applied, type: Integer
    field :validation_type, type: String
    field :fact_types, type: Hash
    
    index({ date: 1 }, { name: 'date_index' })
    index({ initial_decision: 1 }, { name: 'initia_decision_index' })
    index({ final_approval: 1 }, { name: 'final_approval_index' })

    embeds_one :loan_status, class_name: 'Mdb::LoanStatus', inverse_of: :validation_request, autobuild: true
    embeds_many :validation_messages, class_name: 'Mdb::ValidationMessage', inverse_of: :validation_request

    accepts_nested_attributes_for :loan_status, allow_destroy: true, autosave: true
    accepts_nested_attributes_for :validation_messages, allow_destroy: true, autosave: true

  end
end
