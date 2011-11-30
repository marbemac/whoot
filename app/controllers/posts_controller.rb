class PostsController < ApplicationController
  before_filter :authenticate_user!

  def update_feed_display
    if session[:feed_filters][:display].include? params[:value]
      session[:feed_filters][:display].delete(params[:value])
    else
      session[:feed_filters][:display] << params[:value]
    end

    render json: {:replace_target => '#page_content', :content => render_cell(:post, :feed), :event => 'updated_feed_filters'}
  end

  def update_feed_sort
    session[:feed_filters][:sort][:target] = params[:value]

    render json: {:replace_target => '#page_content', :content => render_cell(:post, :feed)}
  end

  def show
    @post = NormalPost.find(params[:id])
    @voters = User.where(:_id.in => @post.voters)
    comments = Comment.where(:post_id => @post.id, :status => 'Active')
    @comments_with_user = User.join(comments)

    details = render_to_string :show

    render json: {:status => 'success', :details => details }
  end

  def new
    if signed_in? && current_user.posted_today?
      redirect_to root_path
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def create
    @post = Post.new(params[:post])
    @post.set_user_snippet(current_user)
    @post.set_location_snippet(current_user)
    @post.disable_current_post(current_user)

    if @post.save
      @post.set_user_post_snippet(current_user)
      #pubnub_message = {
      #        :event => 'post_changed',
      #        :fullname => current_user.fullname,
      #        :user_slug => current_user.fullname.to_url,
      #        :encoded_id => current_user.encoded_id,
      #        :user_id => current_user.id.to_s,
      #        :what => @post.night_type_short,
      #        :night_type => @post.night_type,
      #        :venue_id => @post.venue ? @post.venue.id.to_s : 0,
      #        :id => @post.id.to_s,
      #        :tag => nil
      #}
      if @post.tag
        #pubnub_message[:tag] = {:id => @post.tag.id, :name => @post.tag.name}
      end
      #@pubnub.publish({'channel' => current_user.id.to_s, 'message' => pubnub_message})
      mixpanel_data = {
              'Tag' => (@post.tag ? @post.tag.name : :none),
              'Type' => @post.night_type,
              'City ID' => @post.location.id.to_s,
              'Venue' => (@post.venue ? @post.venue.name : :none),
              'Venue ID' => (@post.venue ? @post.venue.id.to_s : :none)
      }
      @mixpanel.track_event("Normal Post Create", current_user.mixpanel_data.merge!(mixpanel_data))

      response = { :status => :ok, :redirect => request.referer }
      render json: response, status: :created, location: @post
    else
      render json: {:status => :error, :errors => @post.errors}, status: :unprocessable_entity
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
    posts = Post.following_feed(current_user, session[:feed_filters], false).to_a
    venues = Array.new
    venue_ids = Hash.new
    venue_count = 0
    posts.each do |post|
      if post.venue
        unless venue_ids.key? post.venue.id
          venue_ids[post.venue.id] = venues.length
          venues << {:id => post.venue.id.to_s, :coordinates => post.venue.coordinates, :count => 0, :name => post.venue.pretty_name, :location => post.location.full}
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

    @mixpanel.track_event("View Map", current_user.mixpanel_data)

    html = render_to_string :partial => 'map', :locals => {:locations => venues}
    render :json => {:status => 'OK', :content => html, :event => 'post_map_loaded'}
  end

end