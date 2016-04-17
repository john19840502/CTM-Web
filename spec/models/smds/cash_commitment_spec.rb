require 'spec_helper'

describe Smds::CashCommitment do
  describe 'class methods' do
    let(:test_class) { Smds::CashCommitment }

    describe '.editable?' do
      subject { test_class.editable? column_name }

      context 'given certified_on' do
        let(:column_name) { 'certified_on' }
        it { should be true }
      end

      context 'given investor_commitment_number' do
        let(:column_name) { 'investor_commitment_number'}
        it { should be false }
      end
    end

    describe '.display_with' do
      subject { test_class.display_with column_name }

      context 'given total_upb' do
        let(:column_name) { 'total_upb' }
        it { should == :number_to_currency }
      end
    end
  end
end
