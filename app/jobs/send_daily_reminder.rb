class SendDailyReminder
  @queue = :slow

  def self.perform
    User.all().each do |user|
      if !user.posted_today? && user.device_token && user.settings.email_daily
        Notification.send_push_notification(user.device_token, user.device_type, "Create a post for tonight and see what your friends are up to!", user.unread_notification_count, nil)
      end
    end
  end

end