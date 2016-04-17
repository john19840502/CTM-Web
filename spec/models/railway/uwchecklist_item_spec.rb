require 'spec_helper'

describe UwchecklistItem do
  describe 'class methods' do
    describe '#active' do
      let(:active_item)   { create :uwchecklist_item, is_active: true }
      let(:inactive_item) { create :uwchecklist_item, is_active: false }
      subject { UwchecklistItem.active }

      it { should     include active_item }
      it { should_not include inactive_item }
    end
  end

  describe 'instance methods' do
    smoke_test :bullet_type
    smoke_test :value

    subject { build :uwchecklist_item, value: 'check me' }
    #its(:name) { should === 'check me' }

    it 'should return a name' do
      subject.value = 'test'
      subject.name.should eq('test')
    end
  end
end
