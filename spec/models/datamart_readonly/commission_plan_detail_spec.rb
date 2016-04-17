require "spec_helper"

describe CommissionPlanDetail do
  describe 'a real one' do
    subject { CommissionPlanDetail.first }

    context 'with a branch compensation' do
      its(:traditional_split) { should === "" }
    end
  end
end
