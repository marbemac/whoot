class CommentsController < ApplicationController

  def create
    @comment = current_user.comments.new(params[:comment])

    set_content_type('text/javascript')

    if @comment.save
      post = @comment.post
      if post
        user = post.user
        pusher_publish(user.id.to_s+'_private', 'notification', {:content => "#{current_user.fullname} commented on your post."}) if user && current_user.id != user.id
        Notification.add(user, 'comment', (user.settings.email_comment ? true : false), true, false, current_user, [Chronic.parse('today at 12:01am'), Chronic.parse('today at 11:59pm')], nil)
      end
      html = render_to_string :partial => 'teaser', :locals => {:comment => @comment}
      content = {:status => 'OK', :comment => html, :root_id => @comment.post_id, :event => 'comment_created' }
      render json: content, status: :created
    else
      render json: {:status => :ok, :errors => @comment.errors}, status: :unprocessable_entity
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