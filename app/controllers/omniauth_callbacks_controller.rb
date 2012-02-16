class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_by_omniauth(env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = env["omniauth.auth"].except('extra')
      redirect_to new_user_registration_url
    end
  end

  def twitter
    @user = User.find_by_omniauth(env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "your Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_data"] = env["omniauth.auth"].except('extra')
      redirect_to root_path
    end
  end
end