class ServiceController < ActionController::Base
  protect_from_forgery

  # Shows last datamart timestamp, without auth
  def last_transaction
    @skip_analytics = true
    from_date   = DateTime.now - 7.days
    to_date     = DateTime.now + 1.days
    last_trans  = LoanTransaction.select('file_generation_at').where('file_generation_at BETWEEN ? AND ?', from_date, to_date).order('file_generation_at DESC').limit(1).first
    if last_trans
      render text: I18n.localize(last_trans.file_generation_at, :format => :full_american)
    else
      render nothing: true
    end
  end
end
