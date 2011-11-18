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

  def normal_posts
    unless signed_in?
      response = {:status => :not_authenticated}
    else
      posts = NormalPost.following_feed(current_user, params[:feed_filters], true)
      posts = User.join(posts)
      data = []
      posts.each do |post|
        data << NormalPost.convert_for_api(post)
      end
      response = {:status => :ok, :data => data}
    end

    render :json => response
  end

  def comments
    comments = Comment.where(:post_id => params[:id], :status => 'Active')
    comments = User.join(comments)
    data = []
    comments.each do |comment|
      data << Comment.convert_for_api(comment)
    end
    response = {:status => :ok, :data => data}

    render :json => response
  end

  def votes
    post = Post.where(:post_id => params[:id])
    users = User.where(:id => {'$in' => post.voters})
    data = []
    users.each do |user|
      data << User.convert_for_api(user)
    end
    response = {:status => :ok, :data => data}

    render :json => response
  end

  private

  def set_mobile
    request.format = :api
  end

end