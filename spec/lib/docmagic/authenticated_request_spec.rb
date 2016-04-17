require 'spec_helper'
require 'docmagic'

describe DocMagic::AuthenticatedRequest do

  describe ".collection_array" do

    it "should return the array of results" do
      hash = {"foo" => {"bar" => ["bat", "baz"]}}
      expect(subject.collection_array(hash, "foo", "bar")).to eq ["bat", "baz"]
    end

    it "should return singular result as array" do
      hash = {"foo" => {"bar" => "bat"}}
      expect(subject.collection_array(hash, "foo", "bar")).to eq ["bat"]
    end

    it "should handle deep hash nesting" do
      hash = {"foo" => {"bar" => {"bat" => {"baz" => {"quz" => "quuz"}}}}}
      expect(subject.collection_array(hash, "foo", "bar", "bat", "baz", "quz")).to eq ["quuz"]
    end

    it "should handle nil root" do
      expect(subject.collection_array(nil, "foo", "bar")).to eq []
    end

    it "should handle nil collection" do
      expect(subject.collection_array({}, "foo", "bar")).to eq []
    end

    it "should handle empty collection" do
      hash = {"foo" => {}}
      expect(subject.collection_array(hash, "foo", "bar")).to eq []
    end

  end

end