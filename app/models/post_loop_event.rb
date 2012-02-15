class PostLoopEvent < PostEvent
  embeds_one :user_snippet, :as => :user_assignable, :class_name => 'UserSnippet'
end