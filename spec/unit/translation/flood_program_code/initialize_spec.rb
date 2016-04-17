require 'translation/flood_program_code'

describe Translation::FloodProgramCode do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::FloodProgramCode.new(options) }

    context 'with Regular' do
      let(:options) { 'Regular' }

      its(:flood_status_type) { should == 'Regular' }
    end
  end
end
