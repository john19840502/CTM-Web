require 'spec_helper'

describe DatabaseDatamartReadonly do
  describe 'instance methods' do
    describe '#generate_unique_id' do
      subject { Loan.new } #we need a non-abstract subclass of this class to run the instance methods

      its(:readonly?) { should be true }
      specify { lambda { subject.before_destroy }.should raise_error(StandardError)  }
      specify { lambda { subject.before_save }.should raise_error(StandardError)  }
    end
  end
end
