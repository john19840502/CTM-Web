
module Mdb
  class LoanStatus
    include Mongoid::Document

    field :loan_num, type: String
    field :underwriter, type: String
    field :product_code, type: String
    field :channel, type: String
    field :state, type: String
    field :status, type: String
    field :pipeline_status, type: String

    embedded_in :validation_request, class_name: 'Mdb::ValidationRequest'

#    attr_accessible :loan_num, :underwriter, :product_code, :channel, :state,
#      :status, :pipeline_status
  end
end
