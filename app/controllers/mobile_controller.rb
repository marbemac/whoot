class MobileController < ApplicationController
  before_filter :set_mobile

  def post_show
    @user = User.find(params[:id])
    @post = Post.find(@user.current_post.id)
  end

  def set_mobile
    request.format = :mobile
  end

end