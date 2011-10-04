class StagingMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = "marbemac@gmail.com, wquartner@gmail.com, rpc37@cornell.edu"
  end
end