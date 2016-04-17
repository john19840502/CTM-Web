require 'ctm/ms_sql_view'
module Master
  class SpecialFeatureCode < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    # relations
    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :special_feature_codes

    from 'SPECIAL_FEATURE_CODE', as: 'sfc'

    field :id,                  column: 'SPECIAL_FEATURE_CODE_id'
    field :loan_id,             column: 'loanGeneral_Id'
    field :value,               column: '_Value'
    field :position,            column: '_Position'

    def self.sqlserver_create_view
      self.build_query
    end

    def self.for number
      where(position: number).first.try(:value) || '000'
    end
  end
end
