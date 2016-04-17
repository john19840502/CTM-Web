class EditNotesController < RestrictedAccessController
	def getnote
		@note = EditNote.where(note_type: params[:note_type]).first_or_create!.note
		@note = @note.split('|') if @note
		respond_to do |format|
			format.json {render json: @note, success: true}
		end
	end

	def editnote
		@note = EditNote.where(note_type: params[:note_type]).first
		respond_to do |format|
			if can?(:manage, EditNote)
			 	@note.update_attributes(note: params[:notes], user_id: current_user.uuid)
				format.json {render json: @note}
			end
		end
	end

	def can_edit
		@manage = can?(:manage, EditNote)
		#@manage = current_user.roles.include?('bpm')
		respond_to do |format|
			format.json {render json: @manage}
		end			
	end
end