class NormalPostCell < PostCell

  def feed
    @user = current_user
    posts = NormalPost.following_feed(current_user, session[:feed_filters])
    @posts_with_user = User.join(posts)

    render
  end

end