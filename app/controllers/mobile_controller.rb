class MobileController < ApplicationController
  before_filter :set_mobile

  def generate_token
    social_token = params[:token]

    fb = Koala::Facebook::API.new(social_token)
    me = fb.get_object("me")
    if fb && me
      user = User.where("social_connects.uid" => me['id'], 'social_connects.provider' => 'facebook').first
      user.reset_authentication_token!
      token = {:token => user.authentication_token}
    else
      token = {:token => nil}
    end

  end

  private

  def set_mobile
    request.format = :mobile
  end

end