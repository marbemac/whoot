class UsersController < ApplicationController
  before_filter :authenticate_user!
  include ImageHelper

  def show
    @user = User.find_by_encoded_id(params[:id])
    unless @user
      redirect_to root_path
    else
      @title = "#{@user.fullname}" if @user
      @post = NormalPost.current_post(@user)
      if @post
        @post = User.join([@post])[0]
      end
    end
  end

  def default_picture
    user = User.find_by_encoded_id(params[:id])

    dimensions = params[:d]
    style = params[:s]

    url = default_image_url(user, dimensions, style)

    render :text => open(url, "rb").read, :stream => true
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


end
