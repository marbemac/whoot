module NotificationsHelper
  def triggered_users_text_list(triggered_by, base='')
    string = ''
    triggered_by.each_with_index do |user, i|
      if i == triggered_by.length - 1 && triggered_by.length > 1
        string += ' and '
      end
      string += user_link(user, nil, base)
      if i < triggered_by.length - 1 && triggered_by.length > 2
        string += ', '
      end
    end
    string.html_safe
  end

  def action_text(notification, current_user=nil, base='')
    count = notification.triggered_by.length
    case notification.type.to_sym
      when :follow
        count > 1 ? 'are following you' : 'is following you'
      when :also # also signifies that someone has also responded to something your responded to
        "also replied to <a href='#{base+user_path(notification.object_user)}'>#{notification.object_user.first_name}'s</a> post".html_safe
      when :comment
        "commented on your post".html_safe
      else
        "did something weird... this is a mistake and the Whoot team has been notified to fix it!"
    end
  end

  def pretty_time(time)
    a = (Chronic.parse('today at 11:59pm')-time).to_i

    case a
      when 0..86400 then 'Today'
      when 86401..172800 then 'Yesterday'
      when 172801..518400 then time.strftime("%A") # just output the day for anything in the last week
      else time.strftime("%B %d")
    end
  end

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