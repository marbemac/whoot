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
      token = {:status => :ok, :token => user.authentication_token}
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

  private

  def set_mobile
    request.format = :api
  end

end