class PingMailer < ActionMailer::Base
  default :from => "support@thewhoot.com"

  def new_ping(user)
    @user = user
    mail(:to => "#{user.fullname} <#{user.email}>", :subject => "Someone pinged you on The Whoot!")
  end
end