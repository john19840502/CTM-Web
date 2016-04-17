module Esign

  class UpdateBorrowerCompletions
    include ServiceObject

    def call
      ts1 = Time.now
      pids = package_ids
      Rails.logger.info "Processing #{pids.size} packages"
      package_ids.each do |pi|
        begin
          details = DocMagic::EventDetailRequest.new(pi).execute
          if !details.success
            Rails.logger.debug "Could not retrieve event details for package id #{pi}"
            next
          end

          signature_enabled = details.package_info.signature_enabled
          create_records(details) if signature_enabled
          complete_package_processing pi, signature_enabled
        rescue => e
          Rails.logger.warn "Error occured while processing event details for package id #{pi}"
          Rails.logger.warn e
        end
      end
      ts2 = Time.now
      Rails.logger.info "Elapsed time #{ts2 - ts1} ms"
    end

    private

    def create_records details
      loan_number = details.package_info.loan_number
      esign_signers = create_or_retrieve_signers details, loan_number
      create_documents details, loan_number, esign_signers
      events = create_or_retrieve_events details, loan_number, esign_signers
      create_borrower_completions loan_number, esign_signers, events
    end

    def create_or_retrieve_events details, loan_number, esign_signers
      signer_events = []
      details.events.each do |e|
        esign_signer_id = esign_signers.select{|es| es.full_name == e.user_full_name}.first.try!(:id)
        event = Esign::EsignSignerEvent.where(event_type: e.event_type, esign_signer_id: esign_signer_id, event_date: e.event_date, event_note: e.note_description, loan_number: details.package_info.loan_number).first
        if event.nil?
          event = Esign::EsignSignerEvent.new
          event.event_type = e.event_type
          event.esign_signer_id = esign_signer_id
          event.event_date = e.event_date
          event.event_note = e.note_description
          event.loan_number = loan_number
          event.save
        end
        signer_events << event
      end
      signer_events
    end

    def create_borrower_completions loan_number, esign_signers, signer_events
      borrowers = Master::Loan.find_by_loan_num(loan_number).try!(:borrowers)
      return if borrowers.nil?
      signer_events.select{|se| se.event_type == "CompleteEsign"}.each do |event|
        esign_signer = esign_signers.select{|s| s.id == event.esign_signer_id}.first
        completion = Esign::EsignBorrowerCompletion.where(loan_number: loan_number, esign_signer_id: esign_signer.id)
        if completion.empty? && is_borrower?(esign_signer, borrowers)
          completion = Esign::EsignBorrowerCompletion.new
          completion.loan_number = loan_number
          completion.esign_signer = esign_signer
          completion.save
        end
      end
    end

    def create_documents details, loan_number, esign_signers
      details.listings.each do |l|
        document = Esign::EsignDocument.find_by_external_document_id(l.document_id)
        if document.nil?
          document = Esign::EsignDocument.new
          document.loan_number = loan_number
          document.document_description = l.description
          document.document_name = l.document_name
          document.page_count = l.total_page_count
          document.external_document_id = l.document_id
          document.save
        end
        l.document_marks.each do |dm|
          line = Esign::EsignSignatureLine.find_by_external_signature_line_id(dm.mark_id)
          if line.nil?
            line = Esign::EsignSignatureLine.new
            line.esign_document_id = document.id
            line.signature_line_type = dm.mark_type
            line.external_signature_line_id = dm.mark_id
            line.esign_signer_id = signer(dm.signer_id, esign_signers).id unless dm.signer_id.blank?
            line.page_number = dm.page_number_count
            line.save
          elsif line.esign_signer.nil?
            line.signature_line_type = dm.mark_type
            line.esign_signer_id = signer(dm.signer_id, esign_signers).id unless dm.signer_id.blank?
            line.save
          end
        end
      end
    end

    def create_or_retrieve_signers details, loan_number
      esign_signers = []
      details.signers.each do |s|
        signer = Esign::EsignSigner.find_by_external_signer_id(s.signer_id)
        if signer.nil?
          signer = Esign::EsignSigner.new
          signer.loan_number = loan_number
          signer.external_signer_id = s.signer_id
          signer.email = s.email
          signer.full_name = s.full_name
          signer.first_name = s.first_name
          signer.last_name = s.last_name
          signer_action = signer_action(s.signer_id, details.signer_actions)
          if !signer_action.nil?
            signer.consent_date = signer_action.consent_approved_date
            signer.start_date = signer_action.start_date
            signer.completed_date = signer_action.completed_date
          end
          signer.save
        end
        esign_signers << signer
      end
      esign_signers
    end

    def complete_package_processing external_package_id, esign_enabled
      version = Esign::EsignPackageVersion.find_by_external_package_id(external_package_id)
      version.esign_enabled = esign_enabled
      version.processed_date = Time.now
      version.save
    end

    def package_ids
      version_records = Esign::EsignPackageVersion.unprocessed
      version_records.pluck(:external_package_id)
    end

    def is_borrower? esign_signer, borrowers
      borrowers.select{|b| b.first_name.downcase == esign_signer.first_name.downcase && b.last_name.downcase == esign_signer.last_name.downcase}.size > 0
    end

    def signer signer_id, esign_signers
      esign_signers.select{|s| s.external_signer_id == signer_id}.first
    end

    def signer_action signer_id, signer_actions
      signer_actions.select{|sa| sa.signer_id == signer_id}.first
    end

  end
end