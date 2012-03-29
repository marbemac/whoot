class ApiLoopInsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def create
    target_post = Post.find(params[:id])
    if target_post
      target_post.add_voter(current_user)

      if target_post.save
        #Pusher["#{target_post.user_snippet.id.to_s}_private"].trigger('notification', {:content => "#{current_user.fullname} looped in to your night."})
        @user = current_user
        @post_event = target_post.post_events.detect{|e| e.id == current_user.id && e._type == 'PostLoopEvent'}
        Pusher[target_post.user_snippet.id.to_s].trigger('post_event', render_to_string(:template => 'posts/post_event'))

        target_user = User.find(target_post.user_snippet.id)
        if target_user.device_token
          Notification.send_push_notification(target_user.device_token, target_user.device_type, "#{current_user.fullname} looped into your night.")
        end
        response = build_ajax_response(:ok, nil, "You looped into #{target_user.first_name}'s night", nil, { })
        status = 201
      else
        response = build_ajax_response(:error, nil, "Unable to loop in. Please try again later.")
        status = 401
      end
    else
      response = build_ajax_response(:error, nil, 'Target post not found!')
      status = 404
    end

    render :json => response, :status => status
  end

  def destroy
    target_post = Post.find(params[:id])
    if target_post
      target_post.remove_voter(current_user)
      target_post.save
      response = build_ajax_response(:ok, nil, "You looped out", nil, { })
      status = 200
    else
      response = build_ajax_response(:error, nil, 'Target post not found!')
      status = 404
    end

    render :json => response, :status => status
  end
end