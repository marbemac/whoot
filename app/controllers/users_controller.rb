class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => :default_picture
  include ImageHelper

  caches_action :default_picture, :cache_path => Proc.new { |c| "#{c.params[:id].split('-')[0]}-#{c.params[:d][0]}-#{c.params[:d][1]}-#{c.params[:s]}" }

  def show
    @user = params[:id] && params[:id] != "0" ? User.find(params[:id]) : current_user

    not_found("User not found") unless @user
    @title = @user.username
    @description = "Everything #{@user.username} on The Whoot."
    @this = {:group => 'users', :template => 'show'}
  end

  def default_picture
    user = User.find_by_encoded_id(params[:id])
    dimensions = params[:d]
    style = params[:s]

    url = default_image_url(user, dimensions, style, true)

    if Rails.env.development?
      img = open(Rails.public_path+url)
      send_data(
        img.read,
        :type => 'image/png',
        :disposition => 'inline'
      )
    else
      redirect_to url
      #render :nothing => true, :status => 404
    end
  end

  def picture_update
    image = current_user.images.create(:user_id => current_user.id)
    version = AssetImage.new(:isOriginal => true)
    version.id = image.id
    version.image.store!(params[:image_location])
    image.versions << version
    version.save
    current_user.set_default_image(image.id)

    if current_user.save
      [30, 50, 65, 150].each do |width|
        [30, 50, 65, 150].each do |height|
          ['square', nil].each do |mode|
            expire_fragment("#{current_user.public_id.to_i}-#{width}-#{height}-#{mode}")
          end
        end
      end
      ActionController::Base.new.expire_fragment("#{current_user.id.to_s}-undecided")
    end

    render :json => {:status => 'ok'}
  end

  def hover
    @user = User.find_by_slug(params[:id])
    render :partial => 'hover_tab', :user => @user
  end

  def following_users
    @user = User.find_by_encoded_id(params[:id])
    @title = "#{@user.fullname} following" if @user
    @following_users = User.where(:_id.in => @user.following_users).order_by([[:first_name, :asc], [:last_name, :desc]])
    if params[:format] == :api
      following = []
      @following_users.each do |user|
        following << User.convert_for_api(user, current_user)
      end
      response = {:json => {:status => 'ok', :data => following}}
      render response
    end
  end

  def followers
    @user = User.find_by_encoded_id(params[:id])
    @title = "#{@user.fullname} followers" if @user
    @followers = User.followers(@user.id)
    if params[:format] == :api
      followers = []
      @followers.each do |user|
        followers << User.convert_for_api(user, current_user)
      end
      response = {:json => {:status => 'ok', :data => followers}}
      render response
    end
  end

  def settings
    @user = current_user
    unless signed_in?
      redirect_to :root
    end
    @locations = City.order_by([[:state_code, :asc], [:city, :asc]]).all
  end

  def settings_update
    current_user.toggle_setting(params[:setting])
    current_user.save
    render :json => {:status => 'ok', :event => 'settings_updated', :target => '.setting-'+params[:setting], :toggle_classes => ['setB', 'unsetB']}, :status => 201
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

  def tweet
    if params[:tweet_content]
      current_user.twitter.update(params[:tweet_content])
    end

    render :json => build_ajax_response(:ok, root_path, 'Tweet Successful!')
  end

  def update
    current_user.settings.email_comment = (params[:email_comment] == "true") if params[:email_comment]
    current_user.settings.email_mention = (params[:email_ping] == "true") if params[:email_mention]
    current_user.settings.email_follow = (params[:email_follow] == "true") if params[:email_follow]
    current_user.settings.email_follow = (params[:email_daily] == "true") if params[:email_follow]

    current_user.save

    render :nothing => true, status: 200
  end
end
