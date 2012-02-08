class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def my_notifications
    @notifications = Notification.where(
            :user_id => current_user.id
    ).order_by(:created_at, 'desc').limit(5)
    @notifications.each do |notification|
      notification.read = true
      notification.save
    end
    if current_user.unread_notification_count > 0
      current_user.unread_notification_count = 0
      current_user.save
    end
    content = render_to_string :my_notifications

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: {:status => 'success', :content => content, :event => 'my_notifications' } }
    end
  end

end