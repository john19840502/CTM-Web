module Mdb
  class LoanComplianceEventChange
    include Mongoid::Document
    # include Mongoid::Timestamps

    field :username,          type: String
    field :user_id,           type: String
    field :changed_column,    type: String
    field :value_was,         type: String
    field :value_is,          type: String
    field :changed_at,        type: DateTime

    embedded_in :loan_compliance_event_audit

#    attr_accessible :username, :user_id

    validates :username, presence: true
  end
end
