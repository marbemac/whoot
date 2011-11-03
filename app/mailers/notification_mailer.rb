class NotificationMailer < ActionMailer::Base
  default :from => "The Whoot <support@thewhoot.com>"
  layout 'email'

  def new_notifications(user, notifications)
    @user = user
    @notifications = notifications
    mail(:to => "#{user.fullname} <#{user.email}>", :subject => "You've got new notifications on The Whoot")
  end
end