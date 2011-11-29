class CommentsController < ApplicationController

  def create
    post = Post.find(params[:comment][:post_id])
    if post
      @comment = post.add_comment(params[:comment], current_user)

      if @comment.valid?
        user = post.user
        if user && current_user.id != user.id
          @pubnub.publish({'channel' => user.id.to_s+'_private', 'message' => { :event => 'notification', :content => "#{current_user.fullname} commented on your post." }})
          @pubnub.publish({'channel' => post.user_snippet.id.to_s, 'message' => {:event => 'comment_added', :user_id => post.user_snippet.id.to_s, :post_id => post.id.to_s, :count => post.comment_count}})
        end
        Notification.add(user, 'comment', (user.settings.email_comment ? true : false), true, false, current_user, [Chronic.parse('today at 12:01am'), Chronic.parse('today at 11:59pm')], nil)

        html = render_to_string :partial => 'teaser', :locals => {:comment => @comment}
        content = {:status => 'OK', :comment => html, :root_id => post.id, :event => 'comment_created' }
        render json: content, status: :created
      else
        render json: {:status => :ok, :errors => @comment.errors}, status: :unprocessable_entity
      end
    end
  end

  def ajax
    comments = Comment.where(:post_id => params[:post_id], :status => 'Active')
    @comments_with_user = User.join(comments)
    html = render_to_string :partial => 'feed', :locals => {:comments => @comments_with_user}
    response = {:status => 'OK', :content => html }
    render json: response, status: 200
  end

end