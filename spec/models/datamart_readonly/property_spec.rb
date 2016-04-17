require 'spec_helper'

describe Property do
  describe 'instance methods' do
    smoke_test :city
    smoke_test :state
    smoke_test :zip
    # smoke_test :property_type

    it { should be_valid }

  end
end
