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
  end

  class << self
    def convert_for_api(comment)
      {
              :id => comment.id,
              :content => comment.content,
              :created_at => comment.created_at,
              :created_by => User.convert_for_api(comment.created_by)
      }
    end
  end

end