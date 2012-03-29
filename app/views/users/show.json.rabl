object @user
attributes :first_name,
           :last_name,
           :following_users_count,
           :followers_count,
           :unread_notification_count,
           :public_id,
           :slug,
           :location

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

node(:images) do |user|
  {
          #:original => user.image_url(0, 0, 'fit', 'current', true),
          :fit => {
                  :large => "/users/#{user.to_param}/picture?d[]=695&d[]=0&s=fit",
                  :medium => "/users/#{user.to_param}/picture?d[]=190&d[]=0&s=fit"
          },
          :cropped => {
                  :large => "/users/#{user.to_param}/picture?d[]=300&d[]=300&s=fillcropmid",
                  :medium => "/users/#{user.to_param}/picture?d[]=100&d[]=100&s=fillcropmid",
                  :small => "/users/#{user.to_param}/picture?d[]=50&d[]=50&s=fillcropmid",
                  :tiny => "/users/#{user.to_param}/picture?d[]=30&d[]=30&s=fillcropmid"
          }
  }
end