class PostEvent
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include ModelUtilitiesHelper

  embedded_in :post

  embeds_one :user_snippet, :as => :user_assignable, :class_name => 'UserSnippet'

  def comment?
    self._type == "PostCommentEvent"
  end

  def loop?
    self._type == "PostLoopEvent"
  end

  def change?
    self._type == "PostChangeEvent"
  end
end