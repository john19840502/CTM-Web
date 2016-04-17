require 'spec_helper'

describe Smds::GnmaPool do
  it { should be_a Smds::GnmaPool }

  it 'should be able to fetch loans' do
    expect(subject.loans('fake_controller')).to be_empty
  end

  context 'with issue type X' do
    before { subject.issue_type = 'X' }

    its(:pi_account_number) { should == '5580000035' }
    its(:ti_account_number) { should == '5580000043' }
  end

  context 'with issue type C' do
    before { subject.issue_type = 'C' }

    its(:pi_account_number) { should == '5580000094' }
    its(:ti_account_number) { should == '5580000086' }
  end

  context 'with issue type M' do
    before { subject.issue_type = 'M' }

    its(:pi_account_number) { should == '5580000094' }
    its(:ti_account_number) { should == '5580000086' }
  end
end