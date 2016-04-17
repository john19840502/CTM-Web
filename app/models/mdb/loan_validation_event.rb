module Mdb
  class LoanValidationEvent
    include Mongoid::Document

    field :username, type: String
    field :user_id, type: Integer

    embedded_in :loan_validation
    embeds_many :loan_validation_event_details, class_name: 'Mdb::LoanValidationEventDetail'

    #attr_accessible :username, :user_id, :loan_validation_event_details

    accepts_nested_attributes_for :loan_validation_event_details, allow_destroy: true, reject_if: :all_blank

    validates :username, presence: true
  end
end
