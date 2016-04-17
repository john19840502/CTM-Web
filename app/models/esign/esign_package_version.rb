module Esign
  class EsignPackageVersion < ActiveRecord::Base
    validates :external_package_id, uniqueness: true

    scope :unprocessed, -> {where{"processed_date is null"}}
    scope :most_recent_for_loan, ->(loan_num) {where(loan_number: loan_num).order(external_package_id: :desc).first}
  end
end