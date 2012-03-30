object @user

extends "users/show"

attributes :following_users

node :twitter_connected do |user|
  user.twitter ? true : false
end