class SendShoutEmail
  @queue = :medium

  def self.perform(shouter_id, content)
    shouter = User.find(shouter_id)
    users = User.followers(shouter.id)
    posts = Post.where("user_snippet._id" => { "$in" => users.map{|u| u.id} }, :suggestions => "true", "location._id" => shouter.location.id )
    post_ids = posts.map{|p| p.id}
    users.delete_if{ |user| !post_ids.include?(user.id) }

    users.each do |user|
      if user.device_token
        Notification.send_push_notification(user.device_token, user.device_type, "#{shouter.first_name} shouted: #{content}")
      else
        ShoutMailer.shout(shouter, user, content).deliver
      end
    end
  end
end