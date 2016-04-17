require "spec_helper"

describe Servicing::BoardingFilesController do

  before do
    fake_rubycas_login
  end

  describe 'get :index' do
    it "should render index" do
      get :index
      response.should render_template 'index'
    end

    it "should page the results" do
      expect(BoardingFile).to receive(:page).with('2').and_return(['foo'])
      get :index, page: 2
      expect(assigns[:boarding_files]).to eq ['foo']
    end
  end

  describe 'get :download_url' do
    it "should respond with the url of the requested boarding file bundle" do
      bf = BoardingFile.new
      bf.stub_chain(:bundle, :url).and_return('foo')
      BoardingFile.stub(:find).with('123').and_return(bf)
      get :download_url, id: '123'
      response.body.should == 'foo'
    end
  end

  describe 'get :show' do
    let(:bf) { BoardingFile.new }
    let(:loans) { Master::Loan.none }

    before do
      loans.stub includes: loans
      bf.stub loans: loans
      BoardingFile.stub(:find).with('123').and_return(bf)
    end

    it "should assign the boarding file" do
      get :show, id: '123'
      expect(assigns(:bf)).to be bf
    end

    it "should assign the loans" do
      get :show, id: '123'
      expect(assigns(:loans)).to be loans
    end

    it "should assign the total original balance for the loans" do
      a = Master::Loan.new({original_balance: 100}, without_protection: true)
      b = Master::Loan.new({original_balance: 200}, without_protection: true)
      loans = [ a, b ]
      loans.stub includes: loans
      bf.stub loans: loans

      get :show, id: '123'
      expect(assigns(:total)).to eq 300
    end

    it "should render csv when asked" do
      a = Master::Loan.new({original_balance: 100}, without_protection: true)
      b = Master::Loan.new({original_balance: 200}, without_protection: true)
      loans = [ a, b ]
      loans.stub includes: loans
      bf.stub loans: loans

      get :show, id: '123', format: :csv
      expect(response.body).to eq "Loan Num,Amount,UPB,Previously Sent In\n,$100.00,$100.00,Not previously sent\n,$200.00,$200.00,Not previously sent\n"
    end

    it "should list other boarding file names for loans that have them" do
      other_bf = BoardingFile.new({name: 'foo'}, without_protection: true)
      other_bf_2 = BoardingFile.new({name: 'bar'}, without_protection: true)
      a = Master::Loan.new({original_balance: 100}, without_protection: true)
      a.stub boarding_files: [other_bf, bf, other_bf_2]
      loans = [ a ]
      loans.stub includes: loans
      bf.stub loans: loans

      get :show, id: '123', format: :csv
      expect(response.body).to eq "Loan Num,Amount,UPB,Previously Sent In\n,$100.00,$100.00,\"foo, bar\"\n"
    end
  end

  describe "test_one_loan" do

    context "without sufficient permissions" do
      before do
        subject.stub(:can?).with(:manage, BoardingFile).and_return(false)
        get :test_one_loan
      end

      it "should show an error" do
        expect(flash[:error]).to eq 'Insufficient permissions'
      end

      it "should redirect" do
        response.should redirect_to(action: :index)
      end
    end

    it "should not leave an extra boarding file lying around" do
      expect { get :test_one_loan }.not_to change { BoardingFile.count }
    end

    it "should say so if it cannot fine the given loan" do
      get :test_one_loan, loan_num: '10988114'
      response.body.should == 'Could not find loan with loan_num 10988114'
    end

    it "should build an LOI file for a boarding file that has this loan" do
      loan = Master::Loan.find(751)
      Servicing::BoardingFileBuilder.any_instance.should_receive(:build) do |builder, bf|
        bf.loans.map(&:loan_num).should == [ loan.loan_num ]
      end
      get :test_one_loan, loan_num: loan.loan_num
    end

    it "should return the text of the boarding file" do
      loan = Master::Loan.find(751)
      Servicing::BoardingFileBuilder.any_instance.stub build: 'foo'
      get :test_one_loan, loan_num: loan.loan_num
      response.body.should == 'foo'
    end

  end


  describe "test_loans" do

    context "without sufficient permissions" do
      before do
        subject.stub(:can?).with(:manage, BoardingFile).and_return(false)
        get :test_loans
      end

      it "should show an error" do
        expect(flash[:error]).to eq 'Insufficient permissions'
      end

      it "should redirect" do
        response.should redirect_to(action: :index)
      end
    end

    it "should not leave an extra boarding file lying around" do
      expect { get :test_loans }.not_to change { BoardingFile.count }
    end

    it "should say so if it cannot fine the given loan" do
      get :test_loans, loan_num: [ '10988114' ]
      response.body.should == 'Could not find any loans with loan_nums ["10988114"]'
    end

    it "should build an LOI file for a boarding file that has this loan" do
      Servicing::BoardingFileBuilder.any_instance.should_receive(:build) do |builder, bf|
        bf.loans.map(&:loan_num).should == ["1000052", "1000584"]
      end
      get :test_loans, loan_num: ["1000052", "1000584"]
    end

    it "should return the text of the boarding file" do
      Servicing::BoardingFileBuilder.any_instance.stub build: 'foo'
      get :test_loans, loan_num: ["1000052", "1000584"]
      response.body.should == 'foo'
    end

  end
end
