require 'spec_helper'
describe DatabaseDatamart do
  describe 'class methods' do
    subject { DatabaseDatamart }
    its(:sqlserver_create_view) { should be false }
    its(:sqlserver) { should == [] }

    context 'when its table_name is test' do
      before { subject.stub table_name: 'test' }

      its(:sqlserver_drop_view) { should include "DROP VIEW test" }
      its(:sqlserver_base_create) { should include "CREATE VIEW [test]" }
    end
  end
end
