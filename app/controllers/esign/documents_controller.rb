module Esign

  class DocumentsController < RestrictedAccessController

    def show
      request = DocMagic::DocumentRequest.new params[:document_id]
      response = request.execute

      respond_to do |format|
#        format.html do
#          @document_listings = response.document_listings
#        end
        format.pdf do
          raise "Could not retrieve PDF" unless response.success
          @content = Base64.decode64 response.package_content
          send_data @content, filename: "#{params[:document_id]}.pdf", type: :pdf, disposition: :attachment
        end
      end

    end
    
  end

end