class PingMailer < ActionMailer::Base
  include Resque::Mailer
  default :from => "The Whoot <support@thewhoot.com>"
  layout 'email'

  def new_ping(user_id)
    @user = User.find(user_id)
    mail(:to => "#{@user.fullname} <#{@user.email}>", :subject => "Someone pinged you on The Whoot")
  end

  def pinged_user_posted(from_user_id, to_user_id)
    @from_user = User.find(from_user_id)
    @to_user = User.find(to_user_id)
    mail(:to => "#{@from_user.fullname} <#{@to_user.email}>", :subject => "#{@from_user.first_name} posted what #{@from_user.gender_pronoun}'s up to tonight!")
  end
end