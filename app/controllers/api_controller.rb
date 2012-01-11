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
      user = User.find_by_omniauth(omniauth, signed_in_resource=nil)
      user.reset_authentication_token!

      if user && params[:device_token] && !params[:device_token].blank?
        user.device_token = params[:device_token]
        user.save
        Urbanairship.register_device params[:device_token]
      end

      token = {:status => :ok, :token => user.authentication_token, :public_id => user.encoded_id }
    else
      token = {:status => :error, :token => nil}
    end

    render :json => token
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
        data << User.convert_for_api(user)
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
        data << User.convert_for_api(friend)
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