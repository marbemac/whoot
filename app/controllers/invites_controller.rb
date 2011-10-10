class InvitesController < ApplicationController
  before_filter :authenticate_user!

  def index
    fb = current_user.facebook
    friends = fb.get_connections("me", "friends")
    friends_uids = friends.map{|friend| friend['id']}
    @registeredFriends = User.all
  end

  def create
    email = params[:invite][:email]
    current_user.add_invited_email email
    if current_user.errors.empty? && current_user.save
      UserMailer.invite_email(current_user, email).deliver
      render json: { :flash => {:type => :success, :message => "Friend successfully invited!"} }, status: :created
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

end