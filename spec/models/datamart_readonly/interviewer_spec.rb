require 'spec_helper'

describe Interviewer do
  describe 'instance methods' do
    it { should be_valid }

    context "sqlserver views" do
      it { Interviewer::CREATE_VIEW_SQL.should_not be_empty }
      it { Interviewer.should respond_to(:sqlserver_create_view) }
      it { Interviewer.sqlserver_create_view.should_not be_empty }
    end
  end
end
