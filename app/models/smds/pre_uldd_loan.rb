module Smds
  class PreUlddLoan < ActiveRecord::Base
    self.table_name = 'smds.SmdsPreULDDLoans'

    def self.primary_key
      'LnNbr'
    end
  end
end
