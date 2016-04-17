class Admin::EmailTestsController < RestrictedAccessController

  def index
    redirect_to root_path unless current_user.roles.include? 'admin'
  end

  def create
    redirect_to root_path unless current_user.roles.include? 'admin'

    Notifier.send_test_email(params[:emails], params[:email_text]).deliver

    redirect_to admin_email_tests_path, notice: 'Email sent successfully.'
  end
end
