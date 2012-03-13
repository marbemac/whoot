object @user
attributes :first_name,
           :last_name,
           :following_count,
           :followers_count,
           :unread_notification_count,
           :public_id,
           :slug

node(:id) do |user|
  user.id.to_s
end

node(:url) do |user|
  user_url user
end