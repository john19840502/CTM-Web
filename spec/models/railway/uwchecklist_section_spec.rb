require 'spec_helper'

describe UwchecklistSection do
  describe 'class methods' do
    describe '#active' do
      let(:active_section)   { create :uwchecklist_section, is_active: true }
      let(:inactive_section) { create :uwchecklist_section, is_active: false }
      subject { UwchecklistSection.active }

      it { should     include active_section }
      it { should_not include inactive_section }
    end

    describe '#as_list' do
      let(:last_position_section) { create :uwchecklist_section, position: 200 }
      let(:first_position_section) { create :uwchecklist_section, position: 1 }
      let(:middle_position_section) { create :uwchecklist_section, position: 100 }
      subject { UwchecklistSection.as_list }

      it { should == [first_position_section, middle_position_section, last_position_section] }
    end

    describe '#for_page(4)' do
      let(:page_4_section) { create :uwchecklist_section, page: 4 }
      let(:page_5_section) { create :uwchecklist_section, page: 5 }
      subject { UwchecklistSection.for_page(4) }

      it { should     include page_4_section }
      it { should_not include page_5_section }
    end

    let(:column_1_section) { create :uwchecklist_section, column: 1 }
    let(:column_2_section) { create :uwchecklist_section, column: 2 }
    let(:column_3_section) { create :uwchecklist_section, column: 3 }

    describe '#column_1' do
      subject { UwchecklistSection.column_1 }
      it {should     include column_1_section }
      it {should_not include column_2_section }
      it {should_not include column_3_section }
    end

    describe '#column_2' do
      subject { UwchecklistSection.column_2 }
      it {should     include column_2_section }
      it {should_not include column_1_section }
      it {should_not include column_3_section }
    end

    describe '#for_column(3)' do
      subject { UwchecklistSection.for_column(3) }
      it {should     include column_3_section }
      it {should_not include column_1_section }
      it {should_not include column_2_section }
    end

    context 'active page 2 sections exist with length 4, 5, and 6' do
      let(:short)  { create :uwchecklist_section, is_active: true, page: 2, body: "a" * 240 }
      let(:medium) { create :uwchecklist_section, is_active: true, page: 2, body: "a" * 300 }
      let(:long)   { create :uwchecklist_section, is_active: true, page: 2, body: "a" * 360 }

      before do
        short.length.should == 4
        medium.length.should == 5
        long.length.should == 6
      end

      describe '#length' do
        subject { UwchecklistSection.length }
        it { should === 15 }
      end

      describe '#balance_columns' do
        before do
          UwchecklistSection.balance_columns
        end

        it 'should divide the columns evenly' do
          short.reload.column.should === 1
          medium.reload.column.should === 2
          long.reload.column.should === 2
        end
      end
    end
  end

  describe 'instance methods' do
    smoke_test :name
    smoke_test :body
    smoke_test :uwchecklist_items

    context 'section has three checklist_items' do
      before do
        3.times { create :uwchecklist_item, uwchecklist_section: subject }
      end

      its(:checklist_items_count) { should === 3 }
    end

    context 'section has a 120 character body' do
      before do
        subject.body = "a" * 120
      end

      its(:body_size_estimation_count) { should === 2 }
    end

    context 'section has a 200 character body' do
      before do
        subject.body = "a" * 200
      end

      its(:body_size_estimation_count) { should === 3 }
    end

    context 'section has a nil body' do
      before do
        subject.body = nil
      end

      its(:body_size_estimation_count) { should === 0 }
    end

    context 'section has 4 checklist items and a 300 character body' do
      before do
        4.times { create :uwchecklist_item, uwchecklist_section: subject }
        subject.body = "a" * 300
      end

      its(:length) { should === 9 }
    end
  end
end
