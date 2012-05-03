class ApiCommentsController < ApplicationController

  def create
    post = Post.find(params[:post_id])
    if post
      @comment = post.add_comment(params, current_user)

      if @comment.valid?
        @comment.send_notifications(current_user)
        @post_event = post.post_events.detect{|e| e.id == @comment.id}
        Pusher[post.user_snippet.id.to_s].trigger('post_event', @post_event.as_json)

        if post.user.id != current_user.id
          notification = Notification.add(post.user, :comment, true, current_user)
          if notification
            Pusher["#{post.user.id.to_s}_private"].trigger('new_notification', notification.to_json)
          end
        end

        response = build_ajax_response(:ok)
        status = 201
      else
        response = build_ajax_response(:error, nil, nil, @comment.errors)
        status = 422
      end
    else
      response = build_ajax_response(:error, nil, 'Post not found!')
      status = 404
    end

    render :json => response, :status => status
  end

  def destroy
    post = Post.first(conditions: { "post_events._id" => BSON::ObjectId(params[:id]) })
    if post
      comment = post.find_comment(params[:id])
      if can? :destroy, comment
        post.remove_comment(comment)

        content = {:status => 'ok', :event => 'comment_destroyed', :event_id => comment._parent.id, :user_id => post.user_snippet.id}
        render json: content, status: :created
      else
        render json: {:status => 'error', :flash => {:type => "error", :message => "You do not have permission to delete that!"}}, status: 400
      end
    else
      render json: {:status => 'error', :flash => {:type => "error", :message => "Could not find post"}}, status: 400
    end
  end

end