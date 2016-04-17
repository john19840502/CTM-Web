module Mdb
  class ValidationMessage
    include Mongoid::Document

    field :type, type: String
    field :message, type: String
    field :is_reviewed, type: Boolean, default: false
    field :reviewed_by, type: String
    field :reviewed_at, type: DateTime

    embedded_in :validation_request, class_name: 'Mdb::ValidationRequest'
  end
end
