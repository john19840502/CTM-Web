require 'spec_helper'
require 'docmagic'

describe DocMagic::AuthenticationToken do

  describe "self.token" do

    it "should return token if valid one is available" do
      str_token = "kggh8908ysasf434galgha"
      set_token str_token

      token = DocMagic::AuthenticationToken.token
      expect(token.string_token).to eq str_token
    end

    it "should get a new token if none is set" do
      str_token = "jshg9879arsghag9"
      stub_token_request str_token
      set_token nil

      token = DocMagic::AuthenticationToken.token
      expect(token.string_token).to eq str_token
    end

    it "should get a new token if current is expired by mb reckoning" do
      exp_str_token = "alskfjdl987nlknl2342"
      set_token exp_str_token, 601.seconds.ago

      str_token = "lkj345387987sadfalj23"
      stub_token_request str_token

      token = DocMagic::AuthenticationToken.token
      expect(token.string_token).to eq str_token
    end

    it "should get a new token if current is expired by DocMagic" do
      exp_str_token = "lksdlajshdgalkshf"
      set_token exp_str_token, 5.minutes.ago, 60

      str_token = "kqjh43lk4j5yk54jh2"
      stub_token_request str_token

      token = DocMagic::AuthenticationToken.token
      expect(token.string_token).to eq str_token
    end

    it "should keep mb-expired token when fresh token can't be retrieved" do
      exp_str_token = "luhiga87sd6fs8atfa"
      set_token exp_str_token, 1000.seconds.ago, 2000

      stub_token_request nil

      token = DocMagic::AuthenticationToken.token
      expect(token.string_token).to eq exp_str_token
    end

    it "should nullify expired token if fresh token can't be retrieved" do
      exp_str_token = "jhg498asehkj34"
      set_token exp_str_token, 11.minutes.ago, 360.seconds

      stub_token_request nil

      expect{DocMagic::AuthenticationToken.token}.to raise_error /No valid authentication token available./
      expect(DocMagic::AuthenticationToken.class_variable_get :@@current_token).to be_nil
    end

    def stub_token_request str_token
      res = OpenStruct.new
      res.success = str_token.nil? ? false : true
      res.token = str_token
      req = double
      allow(req).to receive(:execute).and_return res
      allow(DocMagic::AuthenticationRequest).to receive(:new).and_return req
    end

    def set_token str_token, ts = Time.now, seconds_before_expire = 7200
      if str_token.nil?
        token = nil
      else
        token = DocMagic::AuthenticationToken.new str_token, seconds_before_expire
        token.instance_variable_set("@ts", ts)
      end
      DocMagic::AuthenticationToken.class_variable_set :@@current_token, token
    end

  end

end