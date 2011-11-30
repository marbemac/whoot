class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => :default_picture
  include ImageHelper

  def show
    @user = User.find_by_encoded_id(params[:id])
    unless @user
      redirect_to root_path
    else
      @title = "#{@user.fullname}" if @user
      @post = Post.current_post(@user)
      if @post
        @post = User.join([@post])[0]
      end
    end
  end

  def default_picture
    user = User.find_by_encoded_id(params[:id])
    dimensions = params[:d]
    style = params[:s]

    url = default_image_url(user, dimensions, style, true)
    if url
      img = open(Rails.env.development? ? Rails.public_path+url : url)
    else
      url = request.protocol + request.host_with_port + '/user-default.gif'
      img = open(url)
    end

    response.headers['Cache-Control'] = 'no-cache'

    if img
      send_data(
        img.read,
        :disposition => 'inline'
      )
    else
      render :nothing => true, :status => 404
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
      # undecided bar teaser
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
        following << User.convert_for_api(user)
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
        followers << User.convert_for_api(user)
      end
      response = {:json => {:status => 'ok', :data => followers}}
      render response
    end
  end

  def settings
    @user = User.find_by_encoded_id(params[:id])
    if !signed_in? || current_user.id != @user.id
      redirect_to :root
    end
  end

  def settings_update
    current_user.toggle_setting(params[:setting])
    current_user.save
    render :json => {:status => 'ok', :event => 'settings_updated', :target => '.setting-'+params[:setting], :toggle_classes => ['setB', 'unsetB']}, :status => 201
  end

end
