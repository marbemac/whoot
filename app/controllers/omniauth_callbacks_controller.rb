class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_by_omniauth(env["omniauth.auth"])

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      if @user.sign_in_count == 0
        sign_in @user
        redirect_to invites_path
      else
        sign_in_and_redirect @user, :event => :authentication
      end
    else
      session["devise.facebook_data"] = env["omniauth.auth"].except('extra')
      redirect_to new_user_registration_url
    end
  end
end