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
              'extra' => {
                      'user_hash' => me
              },
              'credentials' => {
                      'token' => social_token
              }
      }
      user = User.find_by_omniauth(omniauth, signed_in_resource=nil)
      user.reset_authentication_token!
      token = {:status => :ok, :token => user.authentication_token}
    else
      token = {:status => :error, :token => nil}
    end

    render :json => token
  end

  def normal_posts
    unless signed_in?
      response = {:status => :not_authenticated}
    else
      posts = NormalPost.following_feed(current_user, session[:feed_filters], true)
      posts = User.join(posts)
      data = []
      posts.each do |post|
        data << NormalPost.convert_for_api(post)
      end
      response = {:status => :ok, :data => data}
    end

    render :json => response
  end

  private

  def set_mobile
    request.format = :api
  end

end