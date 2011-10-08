class PingMailer < ActionMailer::Base
  default :from => "support@thewhoot.com"

  def new_ping(user)
    @user = user
    mail(:to => "#{user.fullname} <#{user.email}>", :subject => "Someone pinged you on The Whoot")
  end

  def pinged_user_posted(from_user, to_user)
    @from_user = from_user
    @to_user = to_user
    mail(:to => "#{to_user.fullname} <#{to_user.email}>", :subject => "#{from_user.first_name} posted what #{@from_user.gender_pronoun}'s up to tonight!")
  end
end