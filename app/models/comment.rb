class Comment
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :status, :default => 'Active'
  field :content
  field :user_id
  field :post_id

  belongs_to :user
  belongs_to :post

  validates :content, :length => { :in => 2..200 }
  attr_accessible :content, :post_id

end