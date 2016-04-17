require 'translation/flood_program_code'

describe Translation::FloodProgramCode do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::FloodProgramCode.new(options) }

    context 'with flood_status_type = Regular' do
      let(:options) { 'Regular' }

      its(:translate) { should == 'R' }
    end

    context 'with flood_status_type = NonParticipating' do
      let(:options) { 'NonParticipating' }

      its(:translate) { should == 'N' }
    end

    context 'with flood_status_type = something weird' do
      let(:options) { 'SOMETHING WEIRD' }

      its(:translate) { should == nil }
    end
  end
end
