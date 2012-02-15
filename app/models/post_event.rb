class PostEvent
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  embedded_in :post
end