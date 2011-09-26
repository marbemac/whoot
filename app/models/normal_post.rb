class NormalPost < Post

  field :votes, :default => 0
  field :voters, :default => []
  field :invite_post_id

  embeds_many :tags, :as => :taggable, :class_name => 'TagSnippet'

  validate :max_tags, :max_characters

  after_create :update_user_post_snippet
  before_create :process_tags, :disable_current_post

  attr_accessible :invite_post_id

  def add_voter(user)
    unless voters.include? user.id
      self.votes += 1
      self.voters << user.id
    end
  end

  def remove_voter(user)
    if voters.include? user.id
      self.votes -= 1
      self.voters.delete user.id
    end
  end

  def has_voter?(user)
    if voters and voters.include? user.id then true else nil end
  end

  def process_tags
    if self.valid?
      tags.map! do |tag|
        found = Tag.where(:slug => tag.name.to_url).first
        if found
          found.score += 1
          found.save
        else
          found = user.tags.create(name: tag.name)
        end
        tag.id = found.id
        tag.is_trendable = found.is_trendable
        tag
      end
    end
  end

  def disable_current_post
    current_post = NormalPost.current_post(user)
    if (current_post)
      current_post.current = false
      current_post.save
    end
  end

  def update_user_post_snippet
    user.current_post = PostSnippet.new(:night_type => night_type, :created_at => created_at)
    user.save
  end

  class << self
    def current_post(user)
      where(:user_id => user.id, :current => true, :created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5)))).first
    end

    def following_feed(user, feed_filters)
      where(
              :user_id.in => user.following_users,
              :current => true,
              :created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))),
              :night_type.in => feed_filters[:display]
      ).order_by(feed_filters[:sort][:target], feed_filters[:sort][:order])
    end
  end

end