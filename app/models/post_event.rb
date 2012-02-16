class PostEvent
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  embedded_in :post

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