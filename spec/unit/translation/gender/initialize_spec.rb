require 'translation/gender'

describe Translation::Gender do
  describe 'initialize' do
    let(:options) { nil }

    subject { Translation::Gender.new(options) }

    context 'with Female' do
      let(:options) { 'Female' }

      its(:gender_type) { should == 'Female' }
    end
  end
end
