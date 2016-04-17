require 'translation/gender'

describe Translation::Gender do
  describe 'translate' do
    let(:options) { nil }

    subject { Translation::Gender.new(options) }

    context 'with gender_type = Female' do
      let(:options) { 'Female' }

      its(:translate) { should == 'F' }
    end

    context 'with gender_type = Male' do
      let(:options) { 'Male' }

      its(:translate) { should == 'M' }
    end

    context 'with gender_type = something weird' do
      let(:options) { 'SOMETHING WEIRD' }

      its(:translate) { should == nil }
    end
  end
end
