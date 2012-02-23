class SendDailyReminder
  @queue = :slow

  def self.perform
    User.all().each do |user|
      if !user.posted_today? && user.settings.email_daily
        if user.device_token
          Notification.send_push_notification(user.device_token, user.device_type, "Create a post for tonight and see what your friends are up to!")
        else
          UserMailer.daily_email(user).deliver
        end
      end
    end
  end

end