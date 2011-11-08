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
    url = default_image_url(user, dimensions, style, true)
    unless url
      url = request.protocol + request.host_with_port + '/user-default.gif'
    end

    response.headers['Cache-Control'] = 'no-cache'

    render :text => open(url, "rb").read
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
      expire_action :action => :default_picture, :id => current_user.encoded_id
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
  end

  def followers
    @user = User.find_by_encoded_id(params[:id])
    @title = "#{@user.fullname} followers" if @user
    @followers = User.where(:following_users => @user.id).order_by([[:first_name, :asc], [:last_name, :desc]])
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
