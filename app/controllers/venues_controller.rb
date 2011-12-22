class VenuesController < ApplicationController
  before_filter :authenticate_user!

  def attending_venue_map
    @venue = Venue.find(params[:id])
    if @venue
      posts = Post.following(current_user).todays_post.where('venue._id' => @venue.id)
      user_ids = Array.new
      posts.each do |post|
        user_ids << post.user_snippet.id
      end
      @users = User.where(:_id.in => user_ids)
      html = render_to_string :partial => 'attending_venue_map', :locals => {:venue => @venue, :users => @users}
    else
      html = '<div>error</div>'
    end

    render :json => {:status => :ok, :content => html}
  end

  def attending
    @venue = Venue.find(params[:id])
    if @venue
      posts = Post.where('venue._id' => @venue.id, :user_id.in => current_user.following_users, :current => true, :created_at.gte => Post.cutoff_time)
      posts_with_user = User.join(posts)
      html = render_to_string :partial => 'posts/feed', :locals => {:posts => posts_with_user, :user => current_user}
    else
      html = '<div>error</div>'
    end

    render :json => {:status => :ok, :content => html, :event => 'venue_attending_loaded'}
  end

end