class Comment
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :status, :default => 'Active'
  field :content
  field :user_id
  field :post_id

  index(
    [
      [ :post_id, Mongo::DESCENDING ],
      [ :status, Mongo::ASCENDING ],
    ]
  )

  belongs_to :user
  belongs_to :post

  validates :content, :length => { :in => 2..200 }
  attr_accessible :content, :post_id

end