class PurchasedLoan < DatabaseRailway
  before_save :store_current_signature

  scope :unreported, ->{ where(reported: false) }

  def calculate_data_signature
    dump = self.attributes.except('created_at', 'updated_at', 'original_signature', 'current_signature', 'reported').sort.map do |k,v|
      "#{k}:#{v}"
    end.join(',')
    Digest::SHA1.hexdigest dump
  end
  
  def store_current_signature
    self.current_signature = calculate_data_signature
  end

  def self.create_events
    unreported.each do |p|
      p.report_loan
      p.update_attributes(reported: true)
    end
  end

  def round_to_thousands(balance)
    (balance.gsub(',', '').to_f / 1000).round
  end

  def report_loan
    new_balance = round_to_thousands(current_balance) rescue nil
    new_event = LoanComplianceEvent.new(aplnno: cpi_number,
                                      lnamount: new_balance,
                                      appname: name,
                                      propstreet: address,
                                      propcity: city,
                                      propstate: state,
                                      propzip: zipcode,
                                      lntype: loantype,
                                      proptype: proptype,
                                      lnpurpose: purpose,
                                      occupancy: occupncy,
                                      actdate: dispdate,
                                      apeth: appetnic,
                                      capeth: cppetnic,
                                      aprace1: apprace1,
                                      aprace2: apprace2,
                                      aprace3: apprace3,
                                      aprace4: apprace4,
                                      aprace5: apprace5,
                                      caprace1: cpprace1,
                                      caprace2: cpprace2,
                                      caprace3: cpprace3,
                                      caprace4: cpprace4,
                                      caprace5: cpprace5,
                                      apsex: appgendr,
                                      capsex: cppgendr,
                                      tincome: anninc,
                                      hoepa: hoepa_st,
                                      lienstat: lien_st,
                                      action_code: 6,
                                      preappr: 3,
                                      purchtype: 0,
                                      apr: 'NA',
                                      spread: 'NA',
                                      comments: 'Purchased Loan',
                                      reportable: true)

    new_event.save
  end

end
