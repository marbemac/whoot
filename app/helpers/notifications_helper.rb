module NotificationsHelper
  def notification_html_string(notification)
    string = ''
    notification.triggered_by.each_with_index do |user, i|
      if i == notification.triggered_by.length - 1 && notification.triggered_by.length > 1
        string += ' and '
      end
      if i == 5 && notification.triggered_by.length > 6
        string += " and #{notification.triggered_by.length - 6} other people"
        break
      else
        string += link_to user.fullname, user_path(user)

        if i < notification.triggered_by.length - 1 && notification.triggered_by.length > 2
          string += ', '
        end
      end
    end
    string.html_safe
  end
end