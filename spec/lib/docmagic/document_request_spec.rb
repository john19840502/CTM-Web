require 'spec_helper'
require 'docmagic'

describe DocMagic::DocumentRequest do

  context ".parse_html_response" do

    it "should handle HTML error response" do
      request = DocMagic::DocumentRequest.new 87687
      msg = request.parse_html_response access_forbidden
      expect(msg.success).to be_falsey
      expect(msg.messages.size).to eq 1
      expect(msg.messages[0]).to eq "Access to the specified resource has been forbidden."
      expect(msg.document_listings.size).to eq 0
      expect(msg.package_id).to be_nil
      expect(msg.package_content).to be_nil
    end

    def access_forbidden
      "<html><head><title>Apache Tomcat/7.0.52 - Error report</title><style><!--H1 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:22px;} H2 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:16px;} H3 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:14px;} BODY {font-family:Tahoma,Arial,sans-serif;color:black;background-color:white;} B {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;} P {font-family:Tahoma,Arial,sans-serif;background:white;color:black;font-size:12px;}A {color : black;}A.name {color : black;}HR {color : #525D76;}--></style> </head><body><h1>HTTP Status 403 - message</h1><HR size=\"1\" noshade=\"noshade\"><p><b>type</b> Status report</p><p><b>message</b> <u>message</u></p><p><b>description</b> <u>Access to the specified resource has been forbidden.</u></p><HR size=\"1\" noshade=\"noshade\"><h3>Apache Tomcat/7.0.52</h3></body></html>"
    end

  end

  context ".parse_xml_response" do


    it "should process package content" do
      request = DocMagic::DocumentRequest.new 71128
      msg = request.parse_xml_response message
      expect(msg.success).to be_truthy
      expect(msg.package_id).to eq "71128"
      expect(msg.messages.size).to eq 0
      doc_listings = msg.document_listings
      expect(msg.package_content).to eq "JVBERi0xLjQKJeLjz9MKMiAwIG9iago8PC9MZW5ndGggMjk1NC9GaWx0ZXIvRmxhdGVEZWNvZGU+PnN0cmVhbQp4nJWbXc/mtBFA799f8VyCBCGxHSe5a1HhbqUCb6VW6g1adrdUwJYVN/33TWYmzziOj6UKCcEejT3+GJ84T/b3l69fX2J+LHN+vP708s3ry3cvvz+mx7j/o/9+++vjq7+/nx5/+fj47uWrb6dHGNLj9b385zQO49r+n/D//NcoPX36cCQzp0cOcVgkn8++/fz130dWO8jTEEr0TYHW4RL1taNlHnKJvne0hmEt0d8cbWMJ/lyA5ZpE0dw0pmsW/yjYNF3TeJRsveYxFSxcouaCxHjN5IuCpfGaSdlbWq6ZhILN6ZrJWLAcKMe8XTPJZf5p2HdW3qfm2BtVYJyOkAKW/cV12BCmPEwI5zjECywTymOVUCrhUiW0Otz35bxsgw7xTbUtnXysdqWTT9WmdPJHtSedfLhsSf/zH6sd2YzQDenoXb0fHd22o6MfrruxmYNuRke/1nvR0X/qrejol3onNlM/1mGf2ft20oVwFOqVcBTrpXD0qNfC0ZvrYji4rYaj+3I4+/m2Hs7e3hakmaKsiJMfbkvi7I/bmjj7dFsUZ+9uq9JmmXo7FmzOw9w+0Av0rl4wR7/VC+boVjyOPl4XrNmcLpijL24L5uxxWzBnb24L5uznasGcvL0tmLN/3Ras3aIumLMPtwVz9mO1YM0p0QMdxr3kaybl8bnGaybF6Tlt4zWTMm67kKI4wzhfMymO+VUUkLbcKk8xQME+lqsqBihguftHMUABy7KZ0qGkApZTHUKVTznXYasSKiNjrhK6nnbBq+r7qnhCsxSleEKzFqV4QvPkkuIJzdNpL54C/FIVT2ifTFI8BftrXTyhff5I8RTs47V4CvJTXTyQiRRPwV7r4mmPWounPcVH8UD+UjyQiRRPwaa6eAo21MVTsPlaPAUZ6+JpsxjHYysX8J+flXQ99nJBlwKm+djLBSwKNs7h2MsFTCXcjuIqO/28oDlXKW0FXFKVUWH3uE5VRrmEa5XRlwXc5iqjYkXSGKqEij7TftuZMHJaqoSKyKOi53m4nbpa0E9SP0c6uZXzkxTbUKv5SYqtexTz88/rJxcn5cOYlnITaSU/0X9vhfxEf6rq+AluDmwO1ar4iS6PmMsliTJKa/iJymM3lz2V1aYV3MxPC7i1SFa/t/x+ewlBLsZxG/bLruy3L/fFWR+f3r28FyzHv+JxWEKN1w7bhpQYxzDEYPjIrqJ5yL3g1bNu4W2Yue2UfEzixQov3bzTevwfRu9nTFqx6/1hoZN2PnYR0337ncHTkWKFZ0+7hbdh7ODlKHDsekk+3a1gORxxSvYTsLdP1uQT2sLy0IN4C92dsD9sPXdCI7Ut92Z8P3XWHt58XPe24zh74vdJi/vD3="
      expect(doc_listings.size).to be 3
      expect(doc_listings[0].description).to eq "INITIAL DISCLOSURE COVER LETTER"
      expect(doc_listings[0].document_id).to eq "1169829"
      expect(doc_listings[0].document_name).to eq "idcl3.cst.xml"
      expect(doc_listings[0].total_page_count).to eq 1
      expect(doc_listings[1].description).to eq "IMPORTANT INITIAL DISCLOSURE INSTRUCTIONS"
      expect(doc_listings[1].document_id).to eq "1169830"
      expect(doc_listings[1].document_name).to eq "iidi2.mbf.xml"
      expect(doc_listings[1].total_page_count).to eq 2
      expect(doc_listings[2].description).to eq "UNIFORM RESIDENTIAL LOAN APPLICATION"
      expect(doc_listings[2].document_id).to eq "1169831"
      expect(doc_listings[2].document_name).to eq "1003.ltr-a.xml"
      expect(doc_listings[2].total_page_count).to eq 7
    end

    it "should report error when package not found" do
      request = DocMagic::DocumentRequest.new 12312
      msg = request.parse_xml_response message_with_no_package
      expect(msg.success).to be_falsey
      expect(msg.document_listings.size).to eq 0
      expect(msg.package_content).to be_nil
      expect(msg.messages.size).to eq 1
      expect(msg.messages[0]).to eq "Not found."
    end

    it "should report error when no tax form found" do
      request = DocMagic::DocumentRequest.new "71128", "S_124373"
      msg = request.parse_xml_response message_with_no_tax_record
      expect(msg.success).to be_falsey
      expect(msg.messages.size).to eq 1
      expect(msg.messages[0]).to eq "Cannot locate tax transcript certificate sigreq: 71210 documentId: 1170854"
    end

    def message_with_no_package
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<DocMagicESignResponse xmlns=\"http://www.docmagic.com/2011/schemas\" status=\"Failure\">\n<Messages>\n<Message categoryType=\"Server\" messageType=\"Fatal\">Not found.</Message>\n</Messages>\n</DocMagicESignResponse>\n"
    end

    def message
      "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
      "<DocMagicESignResponse xmlns=\"http://www.docmagic.com/2011/schemas\" status=\"Success\">" +
      "<DocumentResponse>" +
      "<DocumentPackage>" +
      "<DocumentListings>" +
      "<DocumentListing>" +
      "<DocumentDescription>INITIAL DISCLOSURE COVER LETTER</DocumentDescription>" +
      "<DocumentIdentifier>1169829</DocumentIdentifier>" +
      "<DocumentName>idcl3.cst.xml</DocumentName>" +
      "<TotalNumberOfPagesCount>1</TotalNumberOfPagesCount>" +
      "</DocumentListing>" +
      "<DocumentListing>" +
      "<DocumentDescription>IMPORTANT INITIAL DISCLOSURE INSTRUCTIONS</DocumentDescription>" +
      "<DocumentIdentifier>1169830</DocumentIdentifier>" +
      "<DocumentName>iidi2.mbf.xml</DocumentName>" +
      "<TotalNumberOfPagesCount>2</TotalNumberOfPagesCount>" +
      "</DocumentListing>" +
      "<DocumentListing>" +
      "<DocumentDescription>UNIFORM RESIDENTIAL LOAN APPLICATION</DocumentDescription>" +
      "<DocumentIdentifier>1169831</DocumentIdentifier>" +
      "<DocumentName>1003.ltr-a.xml</DocumentName>" +
      "<TotalNumberOfPagesCount>7</TotalNumberOfPagesCount>" +
      "<DocumentMarks><DocumentMark signerID=\"S_124373\" documentMarkType=\"Initial\" offsetMeasurementUnitType=\"Pixels\"><DocumentMarkIdentifier>2235201</DocumentMarkIdentifier><OffsetFromBottomNumber>57.0</OffsetFromBottomNumber><OffsetFromLeftNumber>202.0</OffsetFromLeftNumber><PageNumberCount>1</PageNumberCount></DocumentMark><DocumentMark signerID=\"S_124373\" documentMarkType=\"Initial\" offsetMeasurementUnitType=\"Pixels\"><DocumentMarkIdentifier>2235202</DocumentMarkIdentifier><OffsetFromBottomNumber>63.0</OffsetFromBottomNumber><OffsetFromLeftNumber>205.0</OffsetFromLeftNumber><PageNumberCount>2</PageNumberCount></DocumentMark><DocumentMark signerID=\"S_124373\" documentMarkType=\"Initial\" offsetMeasurementUnitType=\"Pixels\"><DocumentMarkIdentifier>2235203</DocumentMarkIdentifier><OffsetFromBottomNumber>57.0</OffsetFromBottomNumber><OffsetFromLeftNumber>203.0</OffsetFromLeftNumber><PageNumberCount>3</PageNumberCount></DocumentMark><DocumentMark signerID=\"S_124373\" documentMarkType=\"Initial\" offsetMeasurementUnitType=\"Pixels\"><DocumentMarkIdentifier>2235204</DocumentMarkIdentifier><OffsetFromBottomNumber>57.0</OffsetFromBottomNumber><OffsetFromLeftNumber>202.0</OffsetFromLeftNumber><PageNumberCount>4</PageNumberCount></DocumentMark><DocumentMark signerID=\"S_124373\" documentMarkType=\"Signature\" offsetMeasurementUnitType=\"Pixels\"><DocumentMarkIdentifier>2235205</DocumentMarkIdentifier><OffsetFromBottomNumber>99.0</OffsetFromBottomNumber><OffsetFromLeftNumber>45.0</OffsetFromLeftNumber><PageNumberCount>5</PageNumberCount></DocumentMark><DocumentMark signerID=\"S_124373\" documentMarkType=\"Initial\" offsetMeasurementUnitType=\"Pixels\"><DocumentMarkIdentifier>2235206</DocumentMarkIdentifier><OffsetFromBottomNumber>57.0</OffsetFromBottomNumber><OffsetFromLeftNumber>202.0</OffsetFromLeftNumber><PageNumberCount>6</PageNumberCount></DocumentMark><DocumentMark signerID=\"S_124373\" documentMarkType=\"Signature\" offsetMeasurementUnitType=\"Pixels\"><DocumentMarkIdentifier>2235207</DocumentMarkIdentifier><OffsetFromBottomNumber>104.0</OffsetFromBottomNumber><OffsetFromLeftNumber>43.0</OffsetFromLeftNumber><PageNumberCount>7</PageNumberCount></DocumentMark></DocumentMarks>" +
      "</DocumentListing>" +

      "</DocumentListings>" +
      "<DocumentPackageContent contentEncodingType=\"Base64\">" +

      # Fragment of PDF code
      "JVBERi0xLjQKJeLjz9MKMiAwIG9iago8PC9MZW5ndGggMjk1NC9GaWx0ZXIvRmxhdGVEZWNvZGU+PnN0cmVhbQp4nJWbXc/mtBFA799f8VyCBCGxHSe5a1HhbqUCb6VW6g1adrdUwJYVN/33TWYmzziOj6UKCcEejT3+GJ84T/b3l69fX2J+LHN+vP708s3ry3cvvz+mx7j/o/9+++vjq7+/nx5/+fj47uWrb6dHGNLj9b385zQO49r+n/D//NcoPX36cCQzp0cOcVgkn8++/fz130dWO8jTEEr0TYHW4RL1taNlHnKJvne0hmEt0d8cbWMJ/lyA5ZpE0dw0pmsW/yjYNF3TeJRsveYxFSxcouaCxHjN5IuCpfGaSdlbWq6ZhILN6ZrJWLAcKMe8XTPJZf5p2HdW3qfm2BtVYJyOkAKW/cV12BCmPEwI5zjECywTymOVUCrhUiW0Otz35bxsgw7xTbUtnXysdqWTT9WmdPJHtSedfLhsSf/zH6sd2YzQDenoXb0fHd22o6MfrruxmYNuRke/1nvR0X/qrejol3onNlM/1mGf2ft20oVwFOqVcBTrpXD0qNfC0ZvrYji4rYaj+3I4+/m2Hs7e3hakmaKsiJMfbkvi7I/bmjj7dFsUZ+9uq9JmmXo7FmzOw9w+0Av0rl4wR7/VC+boVjyOPl4XrNmcLpijL24L5uxxWzBnb24L5uznasGcvL0tmLN/3Ras3aIumLMPtwVz9mO1YM0p0QMdxr3kaybl8bnGaybF6Tlt4zWTMm67kKI4wzhfMymO+VUUkLbcKk8xQME+lqsqBihguftHMUABy7KZ0qGkApZTHUKVTznXYasSKiNjrhK6nnbBq+r7qnhCsxSleEKzFqV4QvPkkuIJzdNpL54C/FIVT2ifTFI8BftrXTyhff5I8RTs47V4CvJTXTyQiRRPwV7r4mmPWounPcVH8UD+UjyQiRRPwaa6eAo21MVTsPlaPAUZ6+JpsxjHYysX8J+flXQ99nJBlwKm+djLBSwKNs7h2MsFTCXcjuIqO/28oDlXKW0FXFKVUWH3uE5VRrmEa5XRlwXc5iqjYkXSGKqEij7TftuZMHJaqoSKyKOi53m4nbpa0E9SP0c6uZXzkxTbUKv5SYqtexTz88/rJxcn5cOYlnITaSU/0X9vhfxEf6rq+AluDmwO1ar4iS6PmMsliTJKa/iJymM3lz2V1aYV3MxPC7i1SFa/t/x+ewlBLsZxG/bLruy3L/fFWR+f3r28FyzHv+JxWEKN1w7bhpQYxzDEYPjIrqJ5yL3g1bNu4W2Yue2UfEzixQov3bzTevwfRu9nTFqx6/1hoZN2PnYR0337ncHTkWKFZ0+7hbdh7ODlKHDsekk+3a1gORxxSvYTsLdP1uQT2sLy0IN4C92dsD9sPXdCI7Ut92Z8P3XWHt58XPe24zh74vdJi/vD3=" +

      "</DocumentPackageContent>" +
      "<PackageIdentifier>71128</PackageIdentifier>" +
      "</DocumentPackage>" +
      "</DocumentResponse>" +
      "</DocMagicESignResponse>"
    end

    def message_with_no_tax_record
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<DocMagicESignResponse xmlns=\"http://www.docmagic.com/2011/schemas\" status=\"Failure\">\n<Messages>\n<Message categoryType=\"Server\" messageType=\"Fatal\">Cannot locate tax transcript certificate sigreq: 71210 documentId: 1170854</Message>\n</Messages>\n</DocMagicESignResponse>\n"
    end

  end

  context ".url" do

    it "should include the package and signer ids" do
      request = DocMagic::DocumentRequest.new "71143", "S_124373"
      expect(request.url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71143/signers/S_124373/verifications/IRS4506"
    end

    it "should include the package id" do
      request = DocMagic::DocumentRequest.new "71143"
      expect(request.url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71143/documents"
    end

  end

end