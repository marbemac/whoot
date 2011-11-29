class UserCell < Cell::Rails

  include Devise::Controllers::Helpers
  helper ImageHelper
  helper UsersHelper

  def sidebar
    if signed_in?
      @user = current_user
      @my_post = Post.current_post(@user)
      @undecided = User.undecided(@user).order_by([[:first_name, :asc], [:last_name, :desc]])
      render
    end
  end

end