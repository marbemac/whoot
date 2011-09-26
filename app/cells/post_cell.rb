class PostCell < Cell::Rails

  include Devise::Controllers::Helpers
  helper ImageHelper
  helper UsersHelper

  def create
    @user = current_user
    @my_post = NormalPost.current_post(@user)
    render
  end


end