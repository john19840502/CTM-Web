class LoanNotesController < RestrictedAccessController
    
  load_and_authorize_resource

  before_filter :ensure_ctm_user, :only => [:edit, :update, :new, :create]

  active_scaffold :loan_note do |config|
    config.list.columns = [:id, :loan_id, :text, :last_updated_by, :note_type, :scheduled_funding]
  end

  def edit
    @loan_note = LoanNote.find(params[:id])
    @loan_note.ctm_user = current_user.ctm_user
  end

  def update
    @loan_note = LoanNote.find(params[:id])
    if @loan_note.update_attributes(loan_note_params)
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    else
      flash[:error] = "Failed to update note"
      render action: :edit
    end
  end

  def new
    @loan_note = LoanNote.new(loan_note_params)
    @loan_note.ctm_user = current_user.ctm_user
    @loan_note.create_user = current_user.ctm_user.id
  end

  def create
    @loan_note = LoanNote.create(loan_note_params)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  private

  def loan_note_params
    params.fetch(:loan_note, {}).permit(:loan_id, :text, :note_type, :ctm_user_id, :create_user)
  end

  def ensure_ctm_user
    unless current_user.ctm_user
      render :text => 'You are not currently registered as a user of the CTM system. Please contact your administrator to add you.'
      return false
    end
  end
end
