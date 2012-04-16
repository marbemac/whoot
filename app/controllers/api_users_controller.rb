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

  def change_location
    location = City.find(params[:id])
    if location
      current_user.set_location(location)
      current_user.save
    end

    response = build_ajax_response(:ok, nil, "Location changed to #{location.name}")
    render json: response, status: :created
  end

  def update
    current_user.settings.email_comment = (params[:email_comment] == "true") if params[:email_comment]
    current_user.settings.email_mention = (params[:email_ping] == "true") if params[:email_mention]
    current_user.settings.email_follow = (params[:email_follow] == "true") if params[:email_follow]
    current_user.settings.email_follow = (params[:email_daily] == "true") if params[:email_follow]

    current_user.save

    render :nothing => true, status: 200
  end

  def block_user
    blocked_user = User.find(params[:blocked_id])
    blocked_user.block(current_user)

    if blocked_user.save && current_user.save
      render json: build_ajax_response(:ok, nil, blocked_user.first_name + " is now blocked, and will not see your activity")
    else
      render json: build_ajax_response(:error, nil, "There was an error. Please contact support@thewhoot.com")
    end
  end

  def blocked_users

  end
end