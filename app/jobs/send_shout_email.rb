class SendShoutEmail
  @queue = :medium

  def self.perform(shouter_id, content)
    shouter = User.find(shouter_id)
    users = User.followers(shouter.id)
    posts = Post.where("user_snippet._id" => { "$in" => users.map{|u| u.id} }, :suggestions => "true", "location._id" => shouter.location.id, :created_at.gte => Post.cutoff_time)
    post_user_ids = posts.map{|p| p.user_snippet.id}
    users = users.reject{ |user| !post_user_ids.include?(user.id) }

    users.each do |user|
      puts user.fullname
      if user.device_token
        Notification.send_push_notification(user.device_token, user.device_type, "#{shouter.first_name} shouted: #{content}", user.unread_notification_count)
      else
        ShoutMailer.shout(shouter, user, content).deliver
      end
    end
  end
end