class NotifyFriends
  @queue = :slow

  def self.perform(user_id)
    user = User.find(user_id)
    fb = user.facebook
    if fb
      friends = fb.get_connections("me", "friends")
      friends_uids = friends.map{|friend| friend['id']}
      registeredFriends = User.where(:_id.nin => user.following_users, "social_connects.uid" => {"$in" => friends_uids}, 'social_connects.provider' => 'facebook')
      registeredFriends.each do |friend|
        if friend.device_token
          message = "Your friend " + user.full_name + " has joined The Whoot! Log in to follow " + user.gender_him_her
          Notification.send_push_notification(friend.device_token, friend.device_type, message)
        end
      end
    end
  end
end