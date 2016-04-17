module Mdb
  class LoanValidationEventDetail
    include Mongoid::Document

    field :total_attempts, type: Integer
    field :validation_type, type: String
    field :total_rools_applied, type: Integer
    field :dates, type: Array
    field :status, type: String
    field :pipeline_status, type: String

    field :error_base_messages, type: Array
    field :error_base_messages_hash, type: String
    field :error_warning_messages, type: Array
    field :error_warning_messages_hash, type: String

    embedded_in :loan_validation_event

#    attr_accessible :total_attempts, :validation_type, :total_rools_applied, :dates, :status, :pipeline_status,
#                    :error_base_messages, :error_base_messages_hash, :error_warning_messages, :error_warning_messages_hash

    # validates :message_text, presence: true

    def self.get_hash_value ary
      Digest::SHA1.hexdigest ary.join
    end
  end
end
