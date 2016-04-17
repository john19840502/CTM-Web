require 'rspec/expectations'

def smoke_test(method_name)  
  describe "#{method_name}" do
    it "should not raise an exception" do
      subject.send(method_name)
    end
  end
end