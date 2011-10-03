class NormalPostCell < PostCell

  def feed
    @user = current_user
    @my_post = NormalPost.current_post(@user)
    posts = NormalPost.following_feed(current_user, session[:feed_filters])
    @posts_with_user = User.join(posts)

    venues = Array.new
    venue_ids = Hash.new
    venue_count = 0
    posts.each do |post|
      if post.venue
        unless venue_ids.key? post.venue.id
          venue_ids[post.venue.id] = venues.length
          venues << {:id => post.venue.id, :coordinates => post.venue.coordinates, :count => 0, :name => post.venue.name}
          venue_count += 1
        end
        venues[venue_ids[post.venue.id]][:count] += 1
      end
    end

    venues.sort_by! {|venue| venue[:count]}
    images = ["map_pin_fill_14x23.png","map_pin_fill_18x29.png","map_pin_fill_24x38.png","map_pin_fill_30x48.png"]
    divider= venue_count / 4
    @venues = venues.each_with_index do |venue, i|
      if venue_count < 5
        venue[:image] = images[1]
      else
        if i < divider
          venue[:image] = images[0]
        elsif i < divider*2
          venue[:image] = images[1]
        elsif i < divider*3
          venue[:image] = images[2]
        else
          venue[:image] = images[3]
        end
      end
    end

    render
  end

end