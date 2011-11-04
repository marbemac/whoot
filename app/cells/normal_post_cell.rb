class NormalPostCell < PostCell

  def feed
    @user = current_user
    @my_post = NormalPost.current_post(@user)
    posts = NormalPost.following_feed(current_user, session[:feed_filters], true)
    @posts_with_user = User.join(posts)

    venue_ids = []
    posts.each do |post|
      if post.venue
        unless venue_ids.include? post.venue.id
          venue_ids << post.venue.id
        end
      end
    end

    @trending_venues = Venue.where(:city_id => @user.location.id).order_by([[:popularity, :desc]]).limit(5)
    @my_trending_venues = Venue.where(:_id => {"$in" => venue_ids}, :city_id => @user.location.id).order_by([[:popularity, :desc]]).limit(5)
    @trending_venues = Venue.where(:city_id => @user.location.id).order_by([[:popularity, :desc]]).limit(5)

    render
  end

end