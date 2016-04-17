class Smds::GnmaPoolsController < ApplicationController
  def update
    pool = Smds::GnmaPool.find params[:id]
    pool.update_attributes(update_parameters, without_protection: true)
    respond_with_bip(pool)
  end

  private

  def update_parameters
    params.require(:smds_gnma_pool).permit(Smds::GnmaPool::GNMA_EDITABLE_COLUMNS)
  end
end
