class ApiUsersController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def show
    user = User.find(params[:id])
    not_found("User not found") unless user

    render :json => user
  end

  def me
    render :json => current_user
  end

  def followers
    @user = User.find(params[:id])
    not_found("User not found") unless @user

    @title = (current_user.id == @user.id ? 'Your' : @user.fullname + "'s") + " followers"
    @description = "A list of all users who are following " + @user.fullname
    users = User.where(:following_users => @user.id).order_by(:slug, :asc)

    render :json => users.map {|u| u.as_json unless current_user.blocked_by.include?(u.id)}.compact
  end

  def following_users
    @user = User.find(params[:id])
    not_found("User not found") unless @user

    @title = "Users " + (current_user.id == @user.id ? 'you are' : @user.fullname+' is') + " following"
    @description = "A list of all users who are being followed by " + @user.fullname
    users = User.where(:_id.in => @user.following_users).order_by(:slug, :asc)
    render :json => users.map {|u| u.as_json}
  end

  def undecided
    not_found("User not found") unless current_user
    users = User.undecided(current_user).order_by([[:first_name, :asc], [:last_name, :desc]])
    render :json => users.map {|u| u.as_json}
  end

  def activity
    user = User.find(params[:id])
    not_found("User not found") unless user
    posts = Post.where("user_snippet._id" => user.id).limit(20)
    render :json => posts.map {|p| p.as_json(user)}
  end

  def notifications
    not_found("User not found") unless current_user

    notifications = Notification.where(:user_id => current_user.id).order_by(:created_at, :desc)
    render :json => notifications.map {|n| n.as_json(:user => current_user)}
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
    current_user.settings.email_ping = (params[:email_ping] == "true") if params[:email_ping]
    current_user.settings.email_follow = (params[:email_follow] == "true") if params[:email_follow]
    current_user.settings.email_daily = (params[:email_daily] == "true") if params[:email_daily]

    current_user.save

    render :nothing => true, status: 200
  end

  def block_user
    blocked_user = User.find(params[:id])

    if blocked_user.block(current_user)
      if blocked_user.save && current_user.save
        render json: build_ajax_response(:ok, nil, blocked_user.first_name + " is now blocked, and will not see your activity"), status: 201
      else
        render json: build_ajax_response(:error, nil, "There was an error. Please contact support@thewhoot.com"), status: 400
      end
    else
      render json: build_ajax_response(:error, nil, "That user is already blocked"), status: 422
    end
  end

  def unblock_user
    blocked_user = User.find(params[:id])

    if blocked_user.unblock(current_user)
      if blocked_user.save && current_user.save
        render json: build_ajax_response(:ok, nil, blocked_user.first_name + " is now unblocked, and may see your activity"), status: 200
      else
        render json: build_ajax_response(:error, nil, "There was an error. Please contact support@thewhoot.com"), status: 400
      end
    else
      render json: build_ajax_response(:error, nil, "That user is already blocked"), status: 422
    end
  end

  def blocked_users
    users = User.where(:blocked_by => current_user.id)
    render :json => users.map {|u| u.as_json}
  end
end