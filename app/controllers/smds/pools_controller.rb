class Smds::PoolsController < ApplicationController
  def update
    pool = Smds::Pool.find params[:id]

    pool.update_attributes(update_params, without_protection: true)
    respond_with_bip(pool)
  end

  private

  def update_params
    params.require(:smds_pool).permit(Smds::Pool.editable_columns.map(&:to_sym))
  end
end
