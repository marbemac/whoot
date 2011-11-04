class NormalPostsController < PostsController
  before_filter :authenticate_user!

  def show
    @post = NormalPost.find(params[:id])
    @voters = User.where(:_id.in => @post.voters)
    comments = Comment.where(:post_id => @post.id, :status => 'Active')
    @comments_with_user = User.join(comments)

    details = render_to_string :show

    render json: {:status => 'success', :details => details }
  end

  def new
    @post = Post.new

    render json: @post
  end

  def edit
    @post = Post.find(params[:id])
  end

  def create
    @post = current_user.normal_posts.new(params[:normal_post])

    if @post.save
      pusher_message = {
              :fullname => current_user.fullname,
              :user_slug => current_user.fullname.to_url,
              :encoded_id => current_user.encoded_id,
              :user_id => current_user.id.to_s,
              :what => @post.night_type_short,
              :night_type => @post.night_type,
              :id => @post.id.to_s,
              :tags => []
      }
      @post.tags.each do |tag|
        pusher_message[:tags] << {:id => tag.id, :name => tag.name}
      end
      pusher_publish(current_user.id.to_s, 'post_changed', pusher_message)

      response = { :redirect => request.referer }
      render json: response, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def update
    @post = Post.find(params[:id])

    if @post.update_attributes(params[:post])
      head :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    head :ok
  end

  def map
    posts = NormalPost.following_feed(current_user, session[:feed_filters], false)
    venues = Array.new
    venue_ids = Hash.new
    venue_count = 0
    posts.each do |post|
      if post.venue
        unless venue_ids.key? post.venue.id
          venue_ids[post.venue.id] = venues.length
          venues << {:id => post.venue.id.to_s, :coordinates => post.venue.coordinates, :count => 0, :name => post.venue.name, :location => post.location.full}
          venue_count += 1
        end
        venues[venue_ids[post.venue.id]][:count] += 1
      end
    end

    venues.sort_by! {|venue| venue[:count]}
    venues.reverse!
    images = ["map_pin_fill_14x23.png","map_pin_fill_18x29.png","map_pin_fill_24x38.png","map_pin_fill_30x48.png"]
    venues_with_image = venues.each_with_index do |venue, i|
      venue[:image] = case venue[:count]
        when 1..2 then images[0]
        when 3..6 then images[1]
        when 7..15 then images[2]
        else images[3]
      end
    end

    venues = Hash.new

    venues_with_image.map do |venue|
      venues[venue[:location]] ||= Array.new
      venues[venue[:location]] << venue
    end

    html = render_to_string :partial => 'map', :locals => {:locations => venues}
    render :json => {:status => 'OK', :content => html, :event => 'normal_post_map_loaded'}
  end
end
