require 'spec_helper'

describe Core::OriginatorsController do
  render_views

  before do
    fake_rubycas_login
  end

  describe 'get :index' do
    let(:originators) { BranchEmployee.all }

    context 'without parent parameter' do
      before do
        BranchEmployee.should_receive(:retail).and_return(originators)
        get :index
      end

      it 'should load all retail employees and limit to 20' do
        expect(assigns(:originators).size).to eq(20)
      end
    end

    context 'with parent parameter = branch' do
      context 'with no pid' do
        it 'should load no employees'
      end

      context 'with a pid' do
        it 'should load retail employees for that branch only'
      end
    end

    context 'with parent parameter = compensation' do
      context 'with no pid' do
        it 'should load no employees'
      end

      context 'with a pid' do
        it 'should load retail employees that are on that plan only'
      end
    end
  end


  describe 'get :show' do
    describe 'should look for the right originator' do
      let(:originator) { BranchEmployee.new }

      it 'sets the originator to @originator' do
        originator_id = '12345'
        BranchEmployee.should_receive(:where).with(id: originator_id).and_return(['vitaly', 'abdul', originator])
        get :show, id: originator_id

        expect(assigns(:originator)).to eq(originator)
      end

      it "should be able to show things when the loans for originator get paged" do
        # this test is here because of a bug discovered in the rails 4 upgrade, where 
        # paging over a list of Master::Loans with no explicit ordering would crash because
        # of changes in arel gem.  
        get :show, id: '6963'
      end
    end
  end
end
