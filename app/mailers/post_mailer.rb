class PostMailer < ActionMailer::Base
  include Resque::Mailer
  default :from => "The Whoot <support@thewhoot.com>"
  layout 'email'
end