class InvitesController < ApplicationController
  before_filter :authenticate_user!

  def index
    fb = current_user.facebook
    if fb
      friends = fb.get_connections("me", "friends")
      friends_uids = friends.map{|friend| friend['id']}
      @registeredFriends = User.where("social_connects.uid" => {"$in" => friends_uids}, 'social_connects.provider' => 'facebook').order_by(:created_at, :desc)
    else
      @registeredFriends = Array.new
    end
  end

  def create
    email = params[:invite][:email]
    current_user.add_invited_email email
    if current_user.errors.empty? && current_user.save
      UserMailer.invite_email(current_user, email).deliver
      render json: { :flash => {:type => :success, :message => "Friend successfully invited!"}, :event => 'user_invited' }, status: :created
    else
      render json: { :status => :error, :errors => current_user.errors}, status: :unprocessable_entity
    end
  end

  def invite_phone_numbers
    email = params[:invite][:email]
    current_user.add_invited_email email
    if current_user.errors.empty? && current_user.save
      UserMailer.invite_email(current_user, email).deliver
      render json: { :flash => {:type => :success, :message => "Friend successfully invited!"}, :event => 'user_invited' }, status: :created
    else
      render json: { :status => :error, :errors => current_user.errors}, status: :unprocessable_entity
    end
  end

end