class Comment
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

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
    ActionController::Base.new.expire_fragment("#{has_comments.id.to_s}-teaser")
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

end