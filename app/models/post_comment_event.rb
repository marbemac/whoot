class PostCommentEvent < PostEvent
  embeds_one :comment, :as => :has_comments, :class_name => 'Comment'
end