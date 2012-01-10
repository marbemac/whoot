class CommentsController < ApplicationController

  def create
    post = Post.find(params[:comment][:post_id])
    if post
      @comment = post.add_comment(params[:comment], current_user)

      if @comment.valid?
        user = post.user

        if current_user.id != user.id
          Pusher["#{user.id.to_s}_private"].trigger('notification', {:content => "#{current_user.fullname} commented on your post."})
        end
        Pusher[post.user_snippet.id.to_s].trigger('comment_added', {
                :user_id => post.user_snippet.id.to_s,
                :post_id => post.id.to_s,
                :comment_id => @comment.id.to_s,
                :comment_count => post.comment_count,
                :created_by => @comment.user_snippet.id.to_s
        })
        Notification.add(user, 'comment', (user.settings.email_comment ? true : false), true, false, current_user, [Chronic.parse('today at 12:01am'), Chronic.parse('today at 11:59pm')], nil)

        if params[:format] == :api
          render :json => {:status => 'ok', :data => nil}, :status => :created
        else
          html = render_to_string :partial => 'teaser', :locals => {:comment => @comment}
          content = {:status => 'ok', :comment => html, :root_id => post.id, :user_id => post.user_snippet.id, :event => 'comment_created' }
          render json: content, status: :created
        end
      else
        render json: {:status => 'error', :errors => @comment.errors}, status: :unprocessable_entity
      end
    end
  end

  def destroy
    post = Post.first(conditions: { "comments._id" => BSON::ObjectId(params[:id]) })
    if post
      comment = post.comments.find(params[:id])
      if can? :destroy, comment
        post.remove_comment(comment)

        content = {:status => 'ok', :event => 'comment_destroyed', :comment_id => comment.id, :user_id => post.user_snippet.id}
        render json: content, status: :created
      else
        render json: {:status => 'error', :flash => {:type => "error", :message => "You do not have permission to delete that!"}}, status: 400
      end
    else
      render json: {:status => 'error', :flash => {:type => "error", :message => "Could not find post"}}, status: 400
    end
  end

  def ajax
    post = Post.find(params[:post_id])
    comment = post.comments.detect{|c| c.id.to_s == params[:comment_id]}
    html = render_to_string :partial => 'teaser', :locals => {:comment => comment}
    response = {:status => 'ok', :comment => html }
    render json: response, status: 200
  end

end