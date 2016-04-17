require 'ostruct'
require 'fi_serv_loan'
describe FiServLoan do
  subject { FiServLoan.new(loan) }

  describe 'wrapping a loan with flood_determination_nfip_community_participation_status_type: Regular' do
    let(:loan) { OpenStruct.new(flood_determination_nfip_community_participation_status_type: 'Regular', flood_certification_identifier: nil) }

    its(:flood_program_code)         { should == 'R' }
  end

  describe 'wrapping a loan with flood_determination_nfip_community_participation_status_type: Unknown' do
    let(:loan) { OpenStruct.new(flood_determination_nfip_community_participation_status_type: 'Unknown', flood_certification_identifier: 'asd') }

    its(:flood_program_code)         { should == 'R' }
  end

  describe '' do
    let(:loan) { OpenStruct.new(flood_determination_nfip_community_participation_status_type: ' ', flood_certification_identifier: 'asdasd') }

    its(:flood_program_code)         { should == 'R' }
  end

end