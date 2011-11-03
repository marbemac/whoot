class PostMailer < ActionMailer::Base
  default :from => "The Whoot <support@thewhoot.com>"
  layout 'email'

  def invite_cancelled(user)
    @user = user
    mail(:to => "#{user.fullname} <#{user.email}>", :subject => "Open invite cancelled on The Whoot")
  end
end