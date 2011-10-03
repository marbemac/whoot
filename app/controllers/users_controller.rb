class UsersController < ApplicationController

  def show
    @user = User.find_by_encoded_id(params[:id])
    @post = NormalPost.current_post(@user)
    @post = User.join([@post])[0]
    @voters = User.where(:_id.in => @post.voters)
    comments = Comment.where(:post_id => @post.id, :status => 'Active')
    @comments_with_user = User.join(comments)
  end

  def hover
    @user = User.find_by_slug(params[:id])
    render :partial => 'hover_tab', :user => @user
  end

  def following_users
    @user = User.find_by_encoded_id(params[:id])
    @following_users = User.where(:_id.in => @user.following_users)
  end

  def followers
    @user = User.find_by_encoded_id(params[:id])
    @followers = User.where(:following_users => @user.id)
  end

  def autocomplete
    matches = User.where(:_id.in => current_user.following_users).where(:slug => /#{params[:q].to_url}/i).asc(:username).limit(10)
    response = Array.new
    found_ids = Array.new
    matches.each do |match|
      found_ids << match.id
      @user = match
      response << {username: match.fullname, formattedItem: render_to_string(partial: 'auto_helper')}
    end

    if response.length < 10
      matches = User.where(:_id.nin => found_ids).where(:slug => /#{params[:q].to_url}/i).asc(:username).limit(10-response.length)
      matches.each do |match|
        @user = match
        response << {name: match.fullname, url: user_path(@user), formattedItem: render_to_string(partial: 'auto_helper')}
      end
    end

    render json: response
  end

end
