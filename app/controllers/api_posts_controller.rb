class ApiPostsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def create
    @post = Post.current_post(current_user)

    if params[:venue_address] && !params[:venue_address].blank?
      params[:venue] = {
              :address_string => params[:venue_address],
              :name => params[:venue_name]
      }
    end

    if @post
      @post.attributes = params
      #@post.venue = nil if @post.address_original.blank? && params[:venue_address].blank?
    else
      @post = Post.new(params)
      @post.set_user_snippet(current_user)
    end

    if params[:format] && params[:format] == :api
      @post.entry_point = 'api'
    else
      @post.entry_point = 'website'
    end

    redirect = Post.where("user_snippet._id" => current_user.id).first ? root_path : invites_path

    if @post.save
      #Pusher[current_user.id.to_s].trigger('post_changed', {:post_id => @post.id.to_s, :user_id => current_user.id.to_s})
      #mixpanel_data = {
      #        'Tag' => (@post.tag ? @post.tag.name : 'none'),
      #        'Type' => @post.night_type,
      #        'City' => (@post.location ? @post.location.full : 'none'),
      #        'Format' => @post.entry_point
      #}
      #@mixpanel.track_event("Post Create", current_user.mixpanel_data.merge!(mixpanel_data))
      if !params[:tweet].blank? && current_user.twitter
        current_user.twitter.update(@post.tweet_text)
      end

      response = build_ajax_response(:ok, redirect, 'Posted! Redirecting...')
      render json: response, :status => 201
    else
      render json: build_ajax_response(:error, nil, nil, @post.errors), :status => 422
    end
  end

  def show
    post = Post.find(params[:id])
    render :json => post.as_json(current_user)
  end

  def feed
    user = params[:user_id] ? User.find(params[:user_id]) : current_user
    posts = Post.following_feed(user, true)

    by_location = {}
    posts.each do |post|
      if post.id == current_user.current_post.id
        by_location["0"] = { location: post.location }
        by_location["0"]["posts"] = [post.as_json(current_user)]
      elsif by_location[post.location.id.to_s]
        by_location[post.location.id.to_s]["posts"] << [post.as_json(current_user)]
      else
        by_location[post.location.id.to_s] = { location: post.location }
        by_location[post.location.id.to_s]["posts"] = [post.as_json(current_user)]
      end
    end
    render :json => by_location
  end

end