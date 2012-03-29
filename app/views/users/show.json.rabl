object @user
attributes :first_name,
           :last_name,
           :following_users_count,
           :followers_count,
           :unread_notification_count,
           :public_id,
           :slug,
           :location,
           :current_post

node(:id) do |user|
  user.id.to_s
end

node(:posted_today) do |user|
  if user.class.name == 'User'
    user.posted_today?
  else
    nil
  end
end

node (:pings_today) do |user|
  if user.class.name == 'User'
    if user.pings_today_date && user.pings_today_date >= Post.cutoff_time
      user.pings_today
    else
      []
    end
  end
end

node(:images) do |user|
  {
          :large => "http://graph.facebook.com/#{user.fuid}/picture?type=large",
          :normal => "http://graph.facebook.com/#{user.fuid}/picture?type=normal",
          :small => "http://graph.facebook.com/#{user.fuid}/picture?type=small",
          :square => "http://graph.facebook.com/#{user.fuid}/picture?type=square"
  }
end