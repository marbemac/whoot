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

node(:images) do |user|
  {
          #:original => user.image_url(0, 0, 'fit', 'current', true),
          :fit => {
                  :large => "/users/#{user.to_param}/picture?d[]=695&d[]=0&m=fit",
                  :medium => "/users/#{user.to_param}/picture?d[]=190&d[]=0&m=fit"
          },
          :cropped => {
                  :large => "/users/#{user.to_param}/picture?d[]=300&d[]=300&m=fillcropmid",
                  :medium => "/users/#{user.to_param}/picture?d[]=100&d[]=100&m=fillcropmid",
                  :small => "/users/#{user.to_param}/picture?d[]=50&d[]=50&m=fillcropmid",
                  :tiny => "/users/#{user.to_param}/picture?d[]=30&d[]=30&m=fillcropmid"
          }
  }
end