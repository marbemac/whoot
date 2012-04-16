class ApiPostsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def create
    @post = Post.current_post(current_user)

    if params[:tag]
      params[:tag] = {
              :name => params[:tag]
      }
    end

    if params[:venue_address]
      params[:venue] = {
              :address_string => params[:venue_address],
              :name => params[:venue_name]
      }
    end

    if @post
      @post.attributes = params
      @post.venue = nil if @post.address_original.blank? && params[:venue][:address_string].blank?
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

  def feed
    user = params[:user_id] ? User.find(params[:user_id]) : current_user
    posts = Post.following_feed(user, true)
    render :json => posts.map {|p| p.as_json(:user => current_user)}
  end

end