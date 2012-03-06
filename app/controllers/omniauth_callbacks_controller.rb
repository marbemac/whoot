class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def initialize_mixpanel
    if Rails.env.production?
      token = '3697e1a281169ebe4f972f32c63c1878'
    elsif Rails.env.staging?
      token = 'a42d020f0cad9a401cc8a7879880b7b0'
    else
      token = '4ba8c8fe2bdc121f677297cb6381a9a8'
    end
    @mixpanel = Mixpanel::Tracker.new(token, request.env, true)
  end

  def facebook
    mixpanel = initialize_mixpanel
    @user = User.find_by_omniauth(env["omniauth.auth"], current_user, mixpanel)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = env["omniauth.auth"].except('extra')
      redirect_to new_user_registration_url
    end
  end

  def twitter
    mixpanel = initialize_mixpanel
    @user = User.find_by_omniauth(env["omniauth.auth"], current_user, mixpanel)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "your Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_data"] = env["omniauth.auth"].except('extra')
      redirect_to root_path
    end
  end
end