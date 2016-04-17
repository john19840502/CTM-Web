require "spec_helper"

describe Borrower do

  smoke_test(:position)
  smoke_test(:employments)
  smoke_test(:first_name)
  smoke_test(:last_name)
  smoke_test(:credit_score)

  let(:loan_general) { build_stubbed :loan_general }
  
  describe "#full_name" do
    context "with no first, last, middle, or suffix" do
      before do
        subject.first_name = nil
        subject.last_name = nil
        subject.middle_name = nil
        subject.suffix = nil
      end

      its(:full_name) { should == '' }
    end

    context "with first_name: Jon, last_name: Jones, empty middle and suffix" do
      before do
        subject.first_name = "Jon"
        subject.last_name = "Jones"
        subject.middle_name = ''
        subject.suffix = nil
      end

      its(:full_name) { should == 'Jon Jones'}
    end

    context 'with first_name: Martin, middle_name: Luther, last_name: King, suffix: Jr.' do
      before do
        subject.first_name = "Martin"
        subject.middle_name = "Luther"
        subject.last_name = "King"
        subject.suffix = "Jr."
      end

      its(:full_name) { should == 'Martin Luther King Jr.'}
    end

    context 'with PermanentResidentAlien status' do
      before do
        subject.first_name = "John"
        subject.last_name = "Doe"
        subject.position = 1
        loan_general.stub(:declarations) { [build_stubbed(:declaration, citizenship_residency_type: "PermanentResidentAlien", borrower_id: 'BRW1')]}
        subject.stub(:loan_general) { loan_general }
      end

      its(:citizen?) { should == 'No'}
      its(:permanent_alien?) { should == 'Yes'}
    end

    context 'with PermanentResidentAlien status but wrong borrower' do
      before do
        subject.first_name = "John"
        subject.last_name = "Doe"
        subject.position = 1
        loan_general.stub(:declarations) { [build_stubbed(:declaration, citizenship_residency_type: "PermanentResidentAlien", borrower_id: 'BRW2')]}
        subject.stub(:loan_general) { loan_general }
      end

      its(:citizen?) { should == 'N/A'}
      its(:permanent_alien?) { should == 'N/A'}
    end

    context 'with USCitizen status' do
      before do
        subject.first_name = "John"
        subject.last_name = "Doe"
        subject.position = 2
        loan_general.stub(:declarations) { [build_stubbed(:declaration, citizenship_residency_type: "USCitizen", borrower_id: 'BRW2')]}
        subject.stub(:loan_general) { loan_general }
      end

      its(:citizen?) { should == 'Yes'}
      its(:permanent_alien?) { should be_empty }
    end

    context 'with declaration not existing' do
      before do
        subject.first_name = "John"
        subject.last_name = "Doe"
        subject.position = 2
        loan_general.stub(:declarations) { [] }
        subject.stub(:loan_general) { loan_general }
      end

      its(:citizen?) { should == 'N/A'}
      its(:permanent_alien?) { should == 'N/A' }
    end

    context 'intent to occupy check' do
      before do
        subject.first_name = "John"
        subject.last_name = "Doe"
        subject.position = 2
        loan_general.stub(:declarations) { [build_stubbed(:declaration, intent_to_occupy_type: 'Yes', citizenship_residency_type: "USCitizen", borrower_id: 'BRW2')]}
        subject.stub(:loan_general) { loan_general }
      end

      describe 'is intending to occupy' do
        its(:intent_to_occupy?) { should == 'Yes'}
      end

      describe 'not intending to occupy' do
        before do
          loan_general.stub(:declarations) { [build_stubbed(:declaration, intent_to_occupy_type: 'No', citizenship_residency_type: "USCitizen", borrower_id: 'BRW2')]}
        end

        its(:intent_to_occupy?) { should == 'No'}
      end

      describe 'intent to occupy is unknown' do
        before do
          loan_general.stub(:declarations) { [build_stubbed(:declaration, intent_to_occupy_type: 'No', citizenship_residency_type: "USCitizen", borrower_id: 'BRW1')]}
        end

        its(:intent_to_occupy?) { should == 'N/A'}
      end
    end

    context 'occupying check' do
      before do
        subject.stub(:loan_general) { loan_general }
        subject.stub_chain(:residences,:current,:any?).and_return(true)
      end
      describe 'is ' do
        its(:occupying?) { should == true}
      end
    end
  end
end
