class VenuesController < ApplicationController
  before_filter :authenticate_user!

  def attending_venue_map
    @venue = Venue.find(params[:id])
    if @venue
      posts = NormalPost.following(current_user).todays_post.where('venue._id' => @venue.id)
      user_ids = Array.new
      posts.each do |post|
        user_ids << post.user_id
      end
      @users = User.where(:_id.in => user_ids)
      html = render_to_string :partial => 'attending_venue_map', :locals => {:venue => @venue, :users => @users}
    else
      html = '<div>error</div>'
    end

    render :json => {:status => 'OK', :content => html}
  end

  def attending
    @venue = Venue.find(params[:id])
    if @venue
      posts = NormalPost.where('venue._id' => @venue.id, :user_id.in => current_user.following_users, :current => true, :created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))))
      posts_with_user = User.join(posts)
      html = render_to_string :partial => 'normal_posts/feed', :locals => {:posts => posts_with_user, :user => current_user}
    else
      html = '<div>error</div>'
    end

    render :json => {:status => 'OK', :content => html, :event => 'venue_attending_loaded'}
  end

  def autocomplete
    matches = Venue.where(:city_id => params[:city]).where(:slug => /#{params[:q].to_url}/i).asc(:slug).limit(7)
    response = Array.new
    @venue = Venue.new(:name => "#{params[:q].capitalize} not here. Create venue named #{params[:q].capitalize}", :address => '')
    response << {id: 0, name: params[:q].capitalize, formattedItem: render_to_string(partial: 'autocomplete')}
    matches.each do |match|
      @venue = match
      response << {id: match.id, name: match.name, formattedItem: render_to_string(partial: 'autocomplete')}
    end

    render json: response
  end

end