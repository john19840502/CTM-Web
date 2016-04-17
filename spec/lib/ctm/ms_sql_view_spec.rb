require 'spec_helper'
require 'ctm/ms_sql_view'
require 'lib/ctm/support/sample_model'

describe CTM::MSSqlView do
  before do
    @obj = Object.new
    @obj.extend(CTM::MSSqlView)
  end
  subject { @obj }
  it { should respond_to(:field) }
  it { should respond_to(:join) }
  it { should respond_to(:current_path) }
  it { should respond_to(:path_override) }
  it { should respond_to(:field_list) }
  it { should respond_to(:from) }
  it { should respond_to(:build_query) }


  context '#field' do
    before { build_field }
    it { subject.fields.should include(:some_name) }
  end

  context 'build methods' do
    before do
      build_field
    end
    its(:select_items) { should == ['c.Channel AS some_name'] }
    its(:build_query) { should == "SELECT c.Channel AS some_name FROM LENDER_LOAN_SERVICE.dbo.[CALCULATION] AS c INNER JOIN LENDER_LOAN_SERVICE.dbo.[ACCOUNT_INFO2] AS a2 ON c.LoanGeneralId = a2.LoanGeneralId AND [a2].[Borrower1] = 'BRW1' AND [a2].[Blah] = 'B2' INNER JOIN LENDER_LOAN_SERVICE.dbo.[ACCOUNT_INFO2] AS a3 ON c.LoanGeneralId = a3.LoanGeneralId AND [a3].[Borrower1] = 'BRW2'" }
    its(:build_join) { should == [
      "INNER JOIN LENDER_LOAN_SERVICE.dbo.[ACCOUNT_INFO2] AS a2 ON c.LoanGeneralId = a2.LoanGeneralId AND [a2].[Borrower1] = 'BRW1' AND [a2].[Blah] = 'B2'",
      "INNER JOIN LENDER_LOAN_SERVICE.dbo.[ACCOUNT_INFO2] AS a3 ON c.LoanGeneralId = a3.LoanGeneralId AND [a3].[Borrower1] = 'BRW2'"
    ] }
    its(:current_path) { should == 'LENDER_LOAN_SERVICE.dbo' }
    context '#path_override' do
      before do
        subject.path_override 'SOME_OTHER_PATH'
      end
      its(:current_path) { should == 'SOME_OTHER_PATH' }
    end
  end

  context '#sqlserver_create_view' do
    subject { CTM::Support::SampleModel }
    it { should respond_to(:sqlserver_create_view) }
    its(:sqlserver_create_view) { should_not be_empty }
  end

  context 'joins' do
    before do
      subject.from 'CALCULATION', as: 'c'
      subject.field(:some_name, column: 'Channel', type: DateTime, default: 'NA')
      #subject.join 'ACCOUNT_INFO2', on: 'LoanGeneralId', as: 'a2', type: :inner
    end
    it 'left inner' do
      subject.join 'ACCOUNT_INFO2', on: 'LoanGeneralId', as: 'a2', type: :left_inner
      subject.build_query.should include('LEFT INNER JOIN')
    end
    it 'right inner' do
      subject.join 'ACCOUNT_INFO2', on: 'LoanGeneralId', as: 'a2', type: :right_inner
      subject.build_query.should include('RIGHT INNER JOIN')
    end
    it 'left outer' do
      subject.join 'ACCOUNT_INFO2', on: 'LoanGeneralId', as: 'a2', type: :left_outer
      subject.build_query.should include('LEFT OUTER JOIN')
    end
    it 'right outer' do
      subject.join 'ACCOUNT_INFO2', on: 'LoanGeneralId', as: 'a2', type: :right_outer
      subject.build_query.should include('RIGHT OUTER JOIN')
    end
    it 'outer' do
      subject.join 'ACCOUNT_INFO2', on: 'LoanGeneralId', as: 'a2', type: :outer
      subject.build_query.should include('OUTER JOIN')
    end
    it 'inner' do
      subject.join 'ACCOUNT_INFO2', on: 'LoanGeneralId', as: 'a2', type: :inner
      subject.build_query.should include('INNER JOIN')
    end

    it "on with array" do
      subject.join "ACCOUNT_INFO2", on: ["foo", "bar"], as: 'dkkd', type: :left_outer
      subject.build_query.should include('ON foo = bar')
    end
  end

  context 'errors' do
    it 'from' do
      expect { subject.field(:some_name, column: 'Channel', type: DateTime, default: 'NA') }.to raise_error('from must be set before setting a field!')
    end

    it 'fields' do
      expect { subject.build_query }.to raise_error('You must set at least one field.')
    end

    context 'joins' do
      before do
        subject.from 'CALCULATION', as: 'c'
        subject.field(:some_name, column: 'Channel', type: DateTime, default: 'NA')
      end
      it 'no on' do
        expect { subject.join 'ACCOUNT_INFO2'}.to raise_error('You must provide a string or an array of 2 items for on:')
      end
      it 'too many ons' do
        expect { subject.join 'ACCOUNT_INFO2', on: ['blah', 'foo', 'bar'], as: 'a2', type: :inner }.to raise_error('You must provide 2 items for on:')
      end
      it 'too few ons' do
        expect { subject.join 'ACCOUNT_INFO2', on: ['blah'], as: 'a2', type: :inner }.to raise_error('You must provide 2 items for on:')
      end
    end

    # context "field mapping duplicate" do
    #   # before do
    #   #   subject.from 'CALCULATION', as: 'c'
    #   #   subject.field(:some_name, column: 'Channel', type: DateTime, default: 'NA')
    #   # end

    #   # it 'raises ArgumentError on duplicate' do
    #   #   expect { subject.field(:some_name2, column: 'Channel', type: DateTime, default: 'NA') }.to raise_error('Channel already defined on c.')
    #   # end

    #   pending 'Per Andy (6-10-2013) code that should raise the error is not working currently. Commenting out until further notice'
    # end
  end

  ############## Private Methods ##############
  def build_field
    subject.from 'CALCULATION', as: 'c'
    subject.field(:some_name, column: 'Channel', type: DateTime, default: 'NA')
    subject.join 'ACCOUNT_INFO2', on: 'LoanGeneralId', as: 'a2', type: :inner, and: {'Borrower1' => 'BRW1', 'Blah' => 'B2'}
    subject.join 'ACCOUNT_INFO2', on: 'LoanGeneralId', as: 'a3', type: :inner, and: {'Borrower1' => 'BRW2'}
  end
  private :build_field
end
