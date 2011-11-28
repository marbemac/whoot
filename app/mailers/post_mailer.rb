class PostMailer < ActionMailer::Base
  default :from => "The Whoot <support@thewhoot.com>"
  layout 'email'
end