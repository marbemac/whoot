class PostMailer < ActionMailer::Base
  default :from => "support@thewhoot.com"

  def invite_cancelled(user)
    @user = user
    mail(:to => "#{user.fullname} <#{user.email}>", :subject => "Open invite cancelled on The Whoot")
  end
end