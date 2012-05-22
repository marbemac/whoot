class ShoutsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def create
    post = Post.current_post(current_user)

    event = post.shout(params[:content], current_user)
    if event
      if post.save
        users = User.followers(current_user.id)
        posts = Post.where("user_snippet._id" => { "$in" => users.map{|u| u.id} }, :suggestions => "true", "location._id" => post.location.id )
        post_ids = posts.map{|p| p.id}
        users.delete_if{ |user| !post_ids.include?(user.id) }
        users.each do |user|
          #TODO: Send Notification
          #Notification.send_push_notification(user.device_token, user.device_type, "#{user.first_name} shouted: #{params[:content]}")
        end
      else
        response = build_ajax_response(:error, nil, "Your shout could not be posted", event.errors)
        status = 422
      end
    else
      response = build_ajax_response(:error, nil, "You have already shouted!")
      status = 422
    end

    render :json => response, :status => status
  end

end