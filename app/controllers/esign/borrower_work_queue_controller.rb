module Esign

  class BorrowerWorkQueueController < ApplicationController

    def index

      respond_to do |format|
        format.html
        format.json do
          set_sorted_borrower_completions
        end
      end
    end

    def show
      respond_to do |format|
        format.json do
          @borrower_completion = Esign::EsignBorrowerCompletion.find(params[:id])
        end
      end
    end

    def update
      borrower_completion = Esign::EsignBorrowerCompletion.find(params[:id])
      borrower_completion.update_attribute(:assignee, params[:assignee]) unless params[:assignee].blank?
      borrower_completion.update_attribute(:status, params[:status]) unless params[:status].blank?
      saved = borrower_completion.save if borrower_completion.valid?
      
      respond_to do |format|
        format.json do
          @saved = saved
          @borrower_completion = borrower_completion
        end
        format.html do
          redirect_to action: "index"
        end
      end
    end

    def set_sorted_borrower_completions
      @borrower_completions = Esign::BorrowerCompletionSorter.call Esign::EsignBorrowerCompletion.uncompleted
    end
    
  end

end