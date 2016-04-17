class ErrorTestController < ApplicationController
  def index
    params[:error] = true
    params[:abdul] = 'causes errors'
    raise StandardError, 'This is a test ErrBit Error.'
  end

  def data
  end
end
