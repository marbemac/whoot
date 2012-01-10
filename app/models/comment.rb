class Comment
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include Whoot::Acl

  field :status, :default => 'Active'
  field :content

  index(
    [
      [ :post_id, Mongo::DESCENDING ],
      [ :status, Mongo::ASCENDING ],
    ]
  )

  validates :content, :length => { :in => 2..200 }
  attr_accessible :content

  embeds_one :user_snippet, :as => :user_assignable, :class_name => 'UserSnippet'
  embedded_in :has_comments, polymorphic: true

  before_create :current_user_own
  after_create :clear_caches
  after_destroy :clear_caches

  def set_user_snippet(user)
    self.user_snippet = UserSnippet.new(
            :username => user.username,
            :first_name => user.first_name,
            :last_name => user.last_name,
            :public_id => user.public_id
    )
    self.user_snippet.id = user.id
  end

  def clear_caches
    has_comments.clear_post_cache
  end

  class << self
    def convert_for_api(comments)
      data = []
      comments.each do |comment|
        data << {
                :id => comment.id,
                :content => comment.content,
                :created_at => comment.created_at,
                :created_by => UserSnippet.convert_for_api(comment.user_snippet)
        }
      end
      data
    end
  end

  def current_user_own
    grant_owner(user_snippet.id)
    grant_permission(has_comments.user_snippet.id, "destroy")
  end

end