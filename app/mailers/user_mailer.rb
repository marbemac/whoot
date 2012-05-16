class UserMailer < ActionMailer::Base
  include Resque::Mailer
  default :from => "The Whoot <support@thewhoot.com>"
  layout 'email'

  def welcome_email(user_id)
    @user = User.find(user_id)
    mail(:to => "#{@user.fullname} <#{@user.email}>", :subject => "#{@user.first_name}, welcome to The Whoot")
  end

  def invite_email(user_id, email)
    @user = User.find(user_id)
    mail(:to => "#{email}", :subject => "#{@user.fullname} invites you to join The Whoot")
  end
end