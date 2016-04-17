class Underwriter::ChecklistsController < RestrictedAccessController
  # authorize_resource

  def index
  end

  def search
    id = params[:loan_id]
    format = params[:commit].to_s.include?("PDF") ? :pdf : :html
    if id.present?
      redirect_to underwriter_checklist_path id, format: format
    else
      flash[:error] = "Please enter a Loan ID"
      redirect_to underwriter_checklists_path
    end
  end

  def show
    @loan = Loan.find_by_loan_num(params[:id])
    
    if @loan.nil?
      flash[:error] = "Loan #{params[:id]} not found."
      redirect_to underwriter_checklists_path and return
    else
    
      @checklist_sections = UwchecklistSection.active.as_list
    
      respond_to do |format|
        format.html do
          @record = @loan
          render :layout      => 'uw_checklist'
        end
        format.pdf do
          render :pdf         => "#{@loan.loan_num rescue 'UNKNOWN_LOAN'}_checklist.pdf",
                 :layout      => 'uw_checklist.html',
                 :page_size   => 'Legal',
                 :greyscale   => false,
                 :dpi         => 600,
                 # :disable_smart_shrinking => false,
                 # :footer      => {:html => { :partial => '/underwriter/checklists/partials/page_footer' }}
                 :footer      => { :right => '[page] of [topage]' }
        end # render pdf
      end # respond_to
    end # unless
  end # show
  
end
