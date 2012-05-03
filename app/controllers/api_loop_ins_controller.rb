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
        Pusher[target_post.user_snippet.id.to_s].trigger('post_event', @post_event.as_json)

        target_user = User.find(target_post.user_snippet.id)
        notification = Notification.add(target_user, :loop, true, current_user)
        if notification
          Pusher["#{target_user.id.to_s}_private"].trigger('new_notification', notification.to_json)
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
      Notification.remove(target_post.user, :loop, current_user)
      response = build_ajax_response(:ok, nil, "You looped out", nil, { })
      status = 200
    else
      response = build_ajax_response(:error, nil, 'Target post not found!')
      status = 404
    end

    render :json => response, :status => status
  end
end