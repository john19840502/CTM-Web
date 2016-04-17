require 'open-uri'

puts "Setting up investors"

# This is the page of all mers companies.
url = 'https://www.mersonline.org/mers/mbrsearch/validatembrsearch.jsp'

puts "...retrieving MERS org list from #{url} "

response = open(url).read rescue nil

if response
  # Nokogiri support xpath, which is the tool we need.
  doc = Nokogiri::HTML(response)

  doc.xpath('//td//a').each {|element|
    begin
      # element.attributes['href']
      # => #<Nokogiri::XML::Attr:0x96d9655c name="href" value="validatembrsearch.jsp?as_mbrsearch=1008967"> 
      # Get the ORG_ID from the query string
      org_id = Rack::Utils.parse_nested_query(URI.parse(element.attributes['href'].value).query)['as_mbrsearch']
  
      # Name
      name = element.children.first.content rescue nil
  
      # If we have found an org_id in the URL, then this is most likely a MERS org
      if org_id and name
        # The page includes a link at the bottom that our xpath finds, however 
        MersOrg.find_or_create_by_org_id(org_id, :name => name)
        puts "...#{name}: #{org_id}"
      end
    rescue
      puts "..."
    end
  }

  # Update our known orgs
  MersOrg.find_by_org_id('1000104').update_attribute('local_alias', 'SunTrust Mortgage')
  MersOrg.find_by_org_id('1000115').update_attribute('local_alias', 'CitiMortgage')
  MersOrg.find_by_org_id('1000113').update_attribute('local_alias', 'Wells Fargo Home Mortgage')
  MersOrg.find_by_org_id('1000157').update_attribute('local_alias', 'Bank of America Home Mortgage')
  MersOrg.find_by_org_id('1000375').update_attribute('local_alias', 'GMAC')
  MersOrg.find_by_org_id('1002026').update_attribute('local_alias', 'Central Mortgage Co')
  
  
  # 1001768 Redwood Trust, Inc may not be Redwood Trust from MERSServicer table...
  # 1008022 is not in MERS Data (First Michigan Bank)
  
  MersOrg.find_or_create_by_org_id('1000212', :name => 'US Bank', :local_alias => 'US Bank - Easy D')
  
  
  

else
  puts "Could not get a response from #{url}"
end