class UserMailer < ActionMailer::Base
  default :from => "support@thewhoot.com"

  def welcome_email(user)
    @user = user
    mail(:to => "#{user.fullname} <#{user.email}>", :subject => "#{user.first_name}, welcome to The Whoot")
  end
end