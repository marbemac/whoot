class UserMailer < ActionMailer::Base
  default :from => "support@thewhoot.com"

  def welcome_email(user)
    @user = user
    mail(:to => "#{to_user.fullname} <#{to_user.email}>", :subject => "#{from_user.first_name}, welcome to The Whoot")
  end
end