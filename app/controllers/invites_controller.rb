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
      UserMailer.invite_email(current_user.id.to_s, email).deliver
      render json: { :flash => {:type => :success, :message => "Friend successfully invited!"}, :event => 'user_invited' }, status: :created
    else
      render json: { :status => :error, :errors => current_user.errors}, status: :unprocessable_entity
    end
  end

  def invite_phone_numbers
    numbers = params[:phone_numbers].split(',')

    numbers.each do |number|
      current_user.add_invited_phone number
    end
    current_user.save

    render json: build_ajax_response(:ok), status: :created
  end

  def show_invite_screen
    posts = Post.where("user_snippet._id" => current_user.id).limit(2).to_a
    if posts.length > 1
      show = false
    else
      show = true
    end

    response = build_ajax_response(:ok, nil, nil, nil, {:show => show})
    render json: response, status: 200
  end

end