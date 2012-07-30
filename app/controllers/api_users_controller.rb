class ApiUsersController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def show
    user = User.find(params[:id])
    not_found("User not found") unless user

    render :json => user
  end

  def me
    render :json => current_user.as_json(:show_extra => true)
  end

  def followers
    @user = User.find(params[:id])
    not_found("User not found") unless @user

    @title = (current_user.id == @user.id ? 'Your' : @user.fullname + "'s") + " followers"
    @description = "A list of all users who are following " + @user.fullname
    users = User.where(:following_users => @user.id).order_by(:slug, :asc)

    render :json => users.map {|u| u.as_json unless current_user.hidden?(u)}.compact
  end

  def following_users
    @user = User.find(params[:id])
    not_found("User not found") unless @user

    @title = "Users " + (current_user.id == @user.id ? 'you are' : @user.fullname+' is') + " following"
    @description = "A list of all users who are being followed by " + @user.fullname
    users = User.where(:_id.in => @user.following_users).order_by(:slug, :asc)
    render :json => users.map {|u| u.as_json unless current_user.hidden?(u)}.compact
  end

  def undecided
    not_found("User not found") unless current_user
    users = User.undecided(current_user).order_by([[:first_name, :asc], [:last_name, :desc]])
    render :json => users.map {|u| u.as_json}
  end

  def activity
    user = User.find(params[:id])
    not_found("User not found") unless user
    posts = Post.where("user_snippet._id" => user.id).order_by(:created_at, :desc).limit(20)
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
    current_user.settings.email_comment = %w(true 1).include?(params[:email_comment]) if params[:email_comment]
    current_user.settings.email_ping = %w(true 1).include?(params[:email_ping]) if params[:email_ping]
    current_user.settings.email_loop = %w(true 1).include?(params[:email_loop]) if params[:email_loop]
    current_user.settings.email_follow = %w(true 1).include?(params[:email_follow]) if params[:email_follow]
    current_user.settings.email_daily = %w(true 1).include?(params[:email_daily]) if params[:email_daily]
    if params[:unread_notification_count]
      current_user.unread_notification_count = params[:unread_notification_count]
      if current_user.unread_notification_count == 0
        Notification.where(:user_id => current_user.id).update_all(:read => true)
      end
    end

    current_user.save

    render :json => current_user.as_json(:show_extra => true), status: 200
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

  def analytics
    if current_user.location.city == "New York City"
      following = Post.following_feed(current_user, true).city_feed(current_user.location.id)
      city = Post.city_feed(current_user.location.id)

      analytics = { :following => Post.analytics(following) }
      analytics[:city] = Post.analytics(city)
    else
      analytics = nil
    end

    render :json => analytics
  end

  def night_invite
    #ActionMailer::Base.mail(:from => 'support@thewhoot.com', :to => 'matt@thewhoot.com', :subject => "night_invite params", :body => params.to_json).deliver
    object = params['phone_numbers'] ? params : ActiveSupport::JSON.decode(request.body.read)
    if object["phone_numbers"].blank? && object["user_ids"].blank?
      render json: build_ajax_response(:error, nil, "Both arrays cannot be blank"), status: 422
    else
      night_invite = NightInvite.create(:phone_numbers => object["phone_numbers"], :invited_user_ids => object["user_ids"])

      url = Rails.env.production? ? "http://thewhoot.com/m/p/#{current_user.id}" : "http://staging.thewhoot.com/m/p/#{current_user.id}"
      object["phone_numbers"].each do |number|
        begin
          sms = Moonshado::Sms.new("1#{number.gsub('^0-9', '')}", "#{current_user.fullname} invited you to join #{current_user.gender_him_her} tonight! #{url}")
          sms.deliver_sms
        rescue => e
        end
      end

      object["user_ids"].each do |uid|
        user = User.find(uid)
        if user
          Notification.add(user, :invite, true, current_user)
        end
      end

      render json: build_ajax_response(:ok, nil, "Invite successful"), status: 201
    end
  end
end