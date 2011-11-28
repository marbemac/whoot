class NormalPost < Post

  field :votes, :default => 0
  field :voters, :default => []

  index [[:votes, Mongo::DESCENDING]], :sparse => true

  embeds_one :tag, :as => :taggable, :class_name => 'TagSnippet'

  validate :max_tags, :max_characters

  after_save :update_user_post_snippet
  before_create :process_tag, :disable_current_post, :set_user_post_snippet
  after_create :set_user_location

  attr_accessible :tag

  def add_voter(user)
    unless voters.include? user.id
      self.votes += 1
      self.voters << user.id
      self.user.votes_count += 1
      self.user.save
    end
  end

  def remove_voter(user)
    if voters.include? user.id
      self.votes -= 1
      self.voters.delete user.id
      self.user.votes_count -= 1
      self.user.save
    end
  end

  def has_voter?(user)
    if voters and voters.include? user.id then true else nil end
  end

  def set_user_location
    if venue
      city = City.near(venue.coordinates.reverse).first
      if city && city.id != user.location.id
        user.location = LocationSnippet.new(
                city: city.name,
                state_code: city.state_code,
                coordinates: city.coordinates
        )
        user.location.id = city.id
        user.save
      end
    end
  end

  def process_tag
    if self.valid? && tag && !tag.name.blank?
      found = Tag.where(:slug => tag.name.to_url).first
      if found
        found.score += 1
        found.save
      else
        found = user.tags.create(name: tag.name)
      end
      tag.id = found.id
      tag
    else
      self.tag = nil
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
    if current_changed? && current == true
      user.current_post = PostSnippet.new(:night_type => night_type, :created_at => created_at)
      user.save
    end
  end

  class << self
    def current_post(user)
      where(:created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))), :user_id => user.id, :current => true).first
    end

    def following_feed(user, feed_filters, include_self = false)
      where(
              :created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))),
              :user_id.in => (include_self ? user.following_users << user.id : user.following_users),
              :current => true,
              :night_type.in => feed_filters[:display]
      ).order_by(feed_filters[:sort][:target], feed_filters[:sort][:order])
    end

    def list_feed(users)
      where(
              :created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))),
              :user_id.in => users,
              :current => true
      ).order_by(:created_at, 'desc')
    end

    def following(user)
      where(:user_id.in => user.following_users)
    end

    def todays_post
      where(:created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))), :current => true)
    end

    def convert_for_api(post)
      {
              :id => post.id,
              :comment_count => post.comment_count,
              :votes_count => post.votes,
              :created_at => post.created_at,
              :night_type => post.night_type,
              :created_by => User.convert_for_api(post.created_by),
              :tag => Tag.convert_for_api(post.tag),
              :venue => Venue.convert_for_api(post.venue),
              :voters => voters
      }
    end
  end

end