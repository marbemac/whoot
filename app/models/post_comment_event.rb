class PostCommentEvent < PostEvent
  embeds_one :comment, :as => :has_comments, :class_name => 'Comment'

  def user
    comment.user_snippet
  end

  def icon
    "comment-grey-1614"
  end

  def text
    comment.content
  end
end