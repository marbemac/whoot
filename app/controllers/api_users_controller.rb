class ApiUsersController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def followers
    @user = User.find(params[:id])
    not_found("User not found") unless @user

    @title = (current_user.id == @user.id ? 'Your' : @user.fullname + "'s") + " followers"
    @description = "A list of all users who are following " + @user.fullname
    @users = User.where(:following_users => @user.id).order_by(:slug, :asc)

    render 'users/list'
  end

  def following_users
    @user = User.find(params[:id])
    not_found("User not found") unless @user

    @title = "Users " + (current_user.id == @user.id ? 'you are' : @user.fullname+' is') + " following"
    @description = "A list of all users who are being followed by " + @user.fullname
    @users = User.where(:_id.in => @user.following_users).order_by(:slug, :asc)

    render 'users/list'
  end

  def undecided
    not_found("User not found") unless current_user

    @users = User.undecided(current_user).order_by([[:first_name, :asc], [:last_name, :desc]])

    render 'users/list'
  end

  def posts
    not_found("User not found") unless current_user

    @posts = Post.where("user_snippet._id" => current_user.id).limit(20)
    render 'posts/feed'
  end

  def notifications
    not_found("User not found") unless current_user

    @notifications = Notification.where(:user_id => current_user.id).order_by(:created_at, :desc)
    render 'users/notifications'
  end
end