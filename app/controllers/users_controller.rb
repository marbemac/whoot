class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = User.find_by_encoded_id(params[:id])
    @title = "#{@user.fullname}" if @user
    @post = NormalPost.current_post(@user)
    if @post
      @post = User.join([@post])[0]
    end
  end

  def hover
    @user = User.find_by_slug(params[:id])
    render :partial => 'hover_tab', :user => @user
  end

  def following_users
    @user = User.find_by_encoded_id(params[:id])
    @title = "#{@user.fullname} following" if @user
    @following_users = User.where(:_id.in => @user.following_users)
  end

  def followers
    @user = User.find_by_encoded_id(params[:id])
    @title = "#{@user.fullname} followers" if @user
    @followers = User.where(:following_users => @user.id)
  end

  def autocomplete
    matches = User.where(:_id.in => current_user.following_users).where(:slug => /#{params[:q].to_url}/i).asc(:username).limit(10)
    response = Array.new
    found_ids = Array.new
    matches.each do |match|
      found_ids << match.id
      @user = match
      response << {id: match.id, name: match.fullname, formattedItem: render_to_string(partial: 'autocomplete')}
    end

    if response.length < 10 && !params[:only_following].present?
      matches = User.where(:_id.nin => found_ids).where(:slug => /#{params[:q].to_url}/i).asc(:username).limit(10-response.length)
      matches.each do |match|
        @user = match
        response << {id: match.id, name: match.fullname, url: user_path(@user), formattedItem: render_to_string(partial: 'autocomplete')}
      end
    end

    render json: response
  end

end
