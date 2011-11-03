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
  after_create :update_post_comments

  def update_post_comments
    post.comment_count += 1
    post.save
    Pusher[post.user_id].trigger('comment_added', {:user_id => post.user_id.to_s, :post_id => post_id.to_s, :count => post.comment_count})
  end

end