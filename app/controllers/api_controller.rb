class ApiController < ApplicationController
  #before_filter :set_mobile

  def generate_token
    social_token = params[:token]

    fb = Koala::Facebook::API.new(social_token)
    me = fb.get_object("me")
    if fb && me
      omniauth = {
              'uid' => me['id'],
              'provider' => 'facebook',
              'info' => me,
              'extra' => {
                      'raw_info' => me
              },
              'credentials' => {
                      'token' => social_token
              }
      }
      user = User.find_by_omniauth(omniauth, signed_in_resource=nil, @mixpanel, 'api')
      user.reset_authentication_token!

      token = {:status => :ok, :token => user.authentication_token, :public_id => user.encoded_id, :user => user.as_json }
    else
      token = {:status => :error, :token => nil}
    end

    render :json => token
  end

  def set_device_token
    unless signed_in?
      response = {:status => :not_authenticated}
    else
      if params[:device_token] && params[:device_type] && ['Android', 'IOS'].include?(params[:device_type])
        current_user.device_token = params[:device_token]
        current_user.device_type = params[:device_type]
        current_user.save
        #Urbanairship.register_device params[:device_token] if params[:device_type] == 'IOS'
        status = :ok
      else
        status = :error
      end
      response = {:status => status, :data => []}
    end

    render :json => response
  end

  def posts
    unless signed_in?
      response = {:status => :not_authenticated}
    else
      filters = {
            :display => params[:display] ? params[:display].split(',') : ['working', 'low_in', 'low_out', 'big_out'],
            :sort => {
                    :target => params[:sort] ? params[:sort].split(',')[0] : 'created_at',
                    :order => params[:sort] ? params[:sort].split(',')[1] : 'DESC'
            }
      }
      posts = Post.following_feed(current_user, filters, true)
      data = []
      posts.each do |post|
        data << Post.convert_for_api(post)
      end
      response = {:status => :ok, :data => data}
    end

    render :json => response
  end

  def me
    unless signed_in?
      response = {:json => {:status => 'error'}, :status => :not_authenticated}
    else
      response = {:json => {:status => 'ok', :data => User.convert_for_api(current_user)}}
    end
    render response
  end

  def undecided
    unless signed_in?
      response = {:json => {:status => 'error'}, :status => :not_authenticated}
    else
      undecided = User.undecided(current_user).order_by([[:first_name, :asc], [:last_name, :desc]]).to_a
      data = []
      undecided.each do |user|
        data << User.convert_for_api(user, current_user)
      end
      response = {:json => {:status => 'ok', :data => data}}
    end
    render response
  end

  def facebook_friends
    if signed_in?
      fb = current_user.facebook
      if fb
        friends = fb.get_connections("me", "friends")
        friends_uids = friends.map{|friend| friend['id']}
        @registeredFriends = User.where("social_connects.uid" => {"$in" => friends_uids}, 'social_connects.provider' => 'facebook')
      else
        @registeredFriends = Array.new
      end
      data = []
      @registeredFriends.each do |friend|
        data << (params[:version] == :v1 ? User.convert_for_api(friend, current_user) : friend.as_json)
      end
      status = 'ok'
    else
      status = 'error'
      data = []
    end

    render :json => {:status => status, :data => data}
  end

  private

  def set_mobile
    request.format = :api
  end

end