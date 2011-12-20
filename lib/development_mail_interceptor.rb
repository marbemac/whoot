class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = "marbemac@gmail.com, matt.c.mccormick@gmail.com"
  end
end