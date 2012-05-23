class ShoutMailer < ActionMailer::Base
  default :from => "The Whoot <support@thewhoot.com>"
  layout 'email'

  def shout(shouter, user, content)
    @user = user
    @shouter = shouter
    @content = content
    mail(:to => "#{@user.fullname} <#{@user.email}>", :subject => "#{shouter.first_name} shouted: #{content}")
  end
end