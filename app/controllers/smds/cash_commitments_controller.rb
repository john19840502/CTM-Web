class Smds::CashCommitmentsController < ApplicationController
  def update
    commitment = Smds::CashCommitment.find params[:id]

    commitment.update_attributes(update_params, without_protection: true)
    
    if commitment.try(:certified_on).nil?
      render :nothing => true, :status => 200
    else
      respond_with_bip(commitment) 
    end
  end

  private

  def update_params
    params.require(:smds_cash_commitment).permit(:certified_on)
  end
end
