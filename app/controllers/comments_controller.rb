class CommentsController < ApplicationController

  def create
    post = Post.find(params[:comment][:post_id])
    if post
      @comment = post.add_comment(params[:comment], current_user)

      if @comment.valid?
        @comment.send_notifications(current_user)
        Pusher[post.user_snippet.id.to_s].trigger('comment_added', {
                :user_id => post.user_snippet.id.to_s,
                :post_id => post.id.to_s,
                :comment_id => @comment.id.to_s,
                :comment_count => post.comment_count,
                :created_by => @comment.user_snippet.id.to_s
        })

        if params[:format] == :api
          render :json => {:status => 'ok', :data => nil}, :status => :created
        else
          html = render_to_string :partial => 'posts/event', :locals => {:event => @comment._parent, :current_user => current_user, :last => nil}
          content = {:status => 'ok', :comment => html, :root_id => post.id, :user_id => post.user_snippet.id, :event => 'comment_created' }
          render json: content, status: :created
        end
      else
        render json: {:status => 'error', :errors => @comment.errors}, status: :unprocessable_entity
      end
    end
  end

  def destroy
    post = Post.first(conditions: { "post_events.comment._id" => BSON::ObjectId(params[:id]) })
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

  def ajax
    post = Post.find(params[:post_id])
    comment = post.comments.detect{|c| c.id.to_s == params[:comment_id]}
    html = render_to_string :partial => 'teaser', :locals => {:event => comment._parent}
    response = {:status => 'ok', :comment => html }
    render json: response, status: 200
  end

end