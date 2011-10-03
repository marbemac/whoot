class UserCell < Cell::Rails

  include Devise::Controllers::Helpers
  helper ImageHelper
  helper UsersHelper

  def sidebar
    if signed_in?
      @user = current_user
      @my_post = NormalPost.current_post(@user)
      if @my_post && @my_post.invite_post_id
        @invite = InvitePost.find(@my_post.invite_post_id)
      end
      @undecided = User.undecided(@user).to_a
      render
    end
  end

end