class UserMailer < ActionMailer::Base
  default :from => "The Whoot <support@thewhoot.com>"
  layout 'email'

  def welcome_email(user)
    @user = user
    mail(:to => "#{user.fullname} <#{user.email}>", :subject => "#{user.first_name}, welcome to The Whoot")
  end

  def invite_email(user, email)
    @user = user
    mail(:to => "#{email}", :subject => "#{user.fullname} invites you to join The Whoot")
  end

  def daily_email(user)
    @user = user
    mail(:to => "#{user.fullname} <#{user.email}>", :subject => "#{user.first_name}, post what you're up to tonight!")
  end
end