require 'spec_helper'
require 'docmagic'

describe DocMagic::Filter do

  context ".by_most_recent_package_version" do

    it "should return the most recent version of each package" do
      listings = [ 
        OpenStruct.new( loan_number: "6000485", package_id: "71566", version_id: 30 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71564", version_id: 29 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71558", version_id: 28 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71556", version_id: 27 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71555", version_id: 26 ),
        OpenStruct.new( loan_number: "1000650", package_id: "71553", version_id: 6 ),
        OpenStruct.new( loan_number: "1000650", package_id: "71552", version_id: 5 ),
        OpenStruct.new( loan_number: "1000650", package_id: "71548", version_id: 4 ),
        OpenStruct.new( loan_number: "1000650", package_id: "71547", version_id: 3 ),
        OpenStruct.new( loan_number: "1000650", package_id: "71546", version_id: 2 ),
        OpenStruct.new( loan_number: "1000650", package_id: "71543", version_id: 1 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71542", version_id: 25 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71541", version_id: 24 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71525", version_id: 23 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71503", version_id: 22 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71500", version_id: 21 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71497", version_id: 20 ),
        OpenStruct.new( loan_number: "1000143", package_id: "71459", version_id: 1 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71446", version_id: 19 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71437", version_id: 18 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71433", version_id: 17 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71429", version_id: 16 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71427", version_id: 15 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71426", version_id: 14 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71424", version_id: 13 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71421", version_id: 12 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71409", version_id: 11 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71407", version_id: 10 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71404", version_id: 9 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71403", version_id: 8 ),
        OpenStruct.new( loan_number: "1000649", package_id: "71311", version_id: 3 ),
        OpenStruct.new( loan_number: "1000649", package_id: "71310", version_id: 2 ),
        OpenStruct.new( loan_number: "1000649", package_id: "71309", version_id: 1 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71304", version_id: 7 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71302", version_id: 6 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71300", version_id: 5 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71297", version_id: 4 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71275", version_id: 3 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71272", version_id: 2 ),
        OpenStruct.new( loan_number: "6000485", package_id: "71271", version_id: 1 ),
        OpenStruct.new( loan_number: "1000648", package_id: "71266", version_id: 20 ),
        OpenStruct.new( loan_number: "1000648", package_id: "71265", version_id: 19 ),
        OpenStruct.new( loan_number: "1000648", package_id: "71264", version_id: 18 ),
        OpenStruct.new( loan_number: "1000648", package_id: "71263", version_id: 17 ),
        OpenStruct.new( loan_number: "1000648", package_id: "71262", version_id: 16 ),
        OpenStruct.new( loan_number: "1000648", package_id: "71261", version_id: 15 ) ]
      retVal = DocMagic::Filter.by_most_recent_package_version listings
      expect(retVal.size).to eq 5
      expect_listing(retVal[0], "6000485", 30)
      expect_listing(retVal[1], "1000650", 6)
      expect_listing(retVal[2], "1000143", 1)
      expect_listing(retVal[3], "1000649", 3)
      expect_listing(retVal[4], "1000648", 20)
      expect(retVal)
    end

    def expect_listing listing, loan_number, version
      expect(listing.loan_number).to eq loan_number
      expect(listing.version_id).to eq version
    end

  end

end