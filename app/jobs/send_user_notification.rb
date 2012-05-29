class SendUserNotification
  @queue = :notifications

  def self.perform(user_id)
    user = User.find(user_id)
    if user
      types = user.settings.notification_types
      unless types.empty?
        notifications = Notification.where(
                :user_id => user.id,
                :type.in => types,
                :active => true,
                :read => false,
                :emailed => false,
                :pushed => false).to_a

        if notifications && notifications.length > 0
          NotificationMailer.new_notifications(user, notifications).deliver
          # Set each notification to emailed
          notifications.each do |notification|
            notification.emailed = true
            notification.save
          end
        end
      end
    end
  end
end