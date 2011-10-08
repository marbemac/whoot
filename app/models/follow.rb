class Follow
  include Mongoid::Document
  include Mongoid::Timestamps

  field :active, :default => true
  field :from_user_id
  field :to_user_id

  index(
    [
      [ :from_user_id, Mongo::ASCENDING ],
      [ :to_user_id, Mongo::ASCENDING ]
    ]
  )

  class << self

    def following(from_user_id, to_user_id)
      Follow.where(:from_user_id => from_user_id, :to_user_id => to_user_id).first
    end

  end

end