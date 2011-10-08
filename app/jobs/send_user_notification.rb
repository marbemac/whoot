class SendUserNotification
  @queue = :notifications

  def self.perform(user_id)
    user = User.find(user_id)
    if user
      notifications = Notification.where(
              :user_id => user.id,
              :type.in => ['follow', 'comment'],
              :active => true,
              :read => false,
              :emailed => false,
              :pushed => false).to_a

      if notifications && notifications.length > 0
        NotificationMailer.new_notifications(user, notifications).deliver
        # Set each notification to emailed
        notifications.each do |notification|
          notification.set_emailed
          notification.save
        end
      end
    end
  end
end