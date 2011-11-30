class UserCell < Cell::Rails

  include ActionController::Caching
  include Devise::Controllers::Helpers
  helper ImageHelper
  helper UsersHelper

  #cache :sidebar do |cell,current_user|
  #  current_user.id.to_s
  #end

  def sidebar(current_user)
    @user = current_user
    @my_post = Post.current_post(@user)
    @undecided = User.undecided(@user).order_by([[:first_name, :asc], [:last_name, :desc]])
    render
  end

end