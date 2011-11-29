class Post
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :status, :default => 'Active'
  field :current, :default => true
  field :night_type
  field :comment_count, :default => 0
  field :votes, :default => 0

  index(
    [
      [ :created_at, Mongo::DESCENDING ],
      [ "user_snippet._id", Mongo::ASCENDING ],
      [ :current, Mongo::DESCENDING ],
      [ :night_type, Mongo::ASCENDING ]
    ]
  )
  index :comment_count
  index "venue._id"
  index "venue.public_id"
  index [["venue.coordinates", Mongo::GEO2D]], :min => -180, :max => 180
  index [["location.coordinates", Mongo::GEO2D]], :min => -180, :max => 180
  index [[:votes, Mongo::DESCENDING]]

  embeds_one :venue, :as => :has_venue, :class_name => 'VenueSnippet'
  embeds_one :location, as: :has_location, :class_name => 'LocationSnippet'
  embeds_one :tag, :as => :taggable, :class_name => 'TagSnippet'
  embeds_one :user_snippet, :as => :user_assignable, :class_name => 'UserSnippet'
  embeds_many :voters, :as => :user_assignable, :class_name => 'UserSnippet'
  embeds_many :comments, :as => :has_comments, :class_name => 'Comment'

  validates :night_type, :inclusion => { :in => ["working", "low_in", "low_out", "big_out"], :message => "Please select a post type below! (working, staying in, relaxing, or partying)" }
  validate :valid_venue, :max_tags, :max_characters
  attr_accessible :night_type, :venue, :tag
  attr_accessor :user_id
  belongs_to :user, :foreign_key => 'user_snippet.id'

  after_save :update_user_post_snippet
  before_create :set_venue_snippet, :process_tag
  after_create :set_user_location, :clear_caches

  def max_tags
    if tag && tag.name.split(' ').length > 3
      errors.add(:tags, "You can only use 3 words! Your tag is #{tag.name.split(' ').length} words long.")
    end
  end

  def max_characters
    if tag && tag.name.length > 40
      errors.add(:tags, "You can only use 40 characters for your tag! You tag has #{tag.name.length} characters.")
    end
  end

  def valid_venue
    if venue && !venue.address_string.blank? && venue.coordinates_string.blank?
      errors.add(:venue_address, "Your venue address is invalid. Please pick a valid address from the dropdown that appears when you start typing.")
    end
  end

  def night_type_short
    names = {:working => "Working", :low_in => "Staying In", :low_out => "Relaxing Out", :big_out => "Partying"}
    names[night_type.to_sym]
  end

  def night_type_noun
    names = {:working => "Work", :low_in => "Stay In", :low_out => "Relax Out", :big_out => "Party"}
    names[night_type.to_sym]
  end

  def created_by
    self[:created_by]
  end

  def set_location_snippet(user)
    self.location = LocationSnippet.new(
          user.location.attributes
    )
  end

  def set_venue_snippet
    target_venue = nil
    if !venue.address_string.blank?
      target_venue = Venue.where(:address_string => venue.address_string).first
      unless target_venue
        target_venue = Venue.new(venue.attributes)
        target_venue.address_string = venue.address_string
        target_venue.user_id = user.id
        target_venue.save!
      end
    end

    if target_venue
      self.venue = VenueSnippet.new(
              name: target_venue.name,
              address: target_venue.address,
              public_id: target_venue.public_id,
              coordinates: target_venue.coordinates
      )
      self.venue.id = target_venue.id
    elsif !venue || !venue.address
      self.venue = nil
    end
  end

  def add_voter(user)
    unless has_voter?(user)
      self.votes += 1
      snippet = UserSnippet.new(
              :username => user.username,
              :first_name => user.first_name,
              :last_name => user.last_name,
              :public_id => user.public_id
      )
      snippet.id = user.id
      self.voters << snippet
      self.user.votes_count += 1
      self.user.save
    end
  end

  def has_voter?(user)
    voters.detect{|v| v.id == user.id}
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

  def disable_current_post(user)
    current_post = Post.current_post(user)
    if (current_post)
      current_post.current = false
      current_post.save
    end
  end

  def set_user_post_snippet(user)
    # Send emails to the users that pinged this user
    unless user.posted_today? || !user.pings_today_date || user.pings_today_date <= Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5)))
      users = User.where(:_id.in => user.pings_today)
      users.each do |to_user|
        PingMailer.pinged_user_posted(user, to_user).deliver
      end
    end
    user.current_post = PostSnippet.new(:night_type => night_type, :created_at => created_at)
    user.save
  end

  def set_user_snippet(user)
    self.user_snippet = UserSnippet.new(
            :username => user.username,
            :first_name => user.first_name,
            :last_name => user.last_name,
            :public_id => user.public_id
    )
    self.user_snippet.id = user.id
  end

  def update_user_post_snippet
    if current_changed? && current == true
      user.current_post = PostSnippet.new(:night_type => night_type, :created_at => created_at)
      user.save
    end
  end

  def add_comment(data, user)
    comment = Comment.new(data)
    comment.set_user_snippet(user)
    if comment.valid?
      self.comments << comment
      self.comment_count += 1
      save
    end
    comment
  end

  def user
    User.find(user_snippet.id)
  end

  def clear_caches
    # this users sidebar
    ActionController::Base.new.expire_cell_state UserCell, :sidebar, user_snippet.id.to_s
    # sidebars of any user following this user (for undecided bar)
    followers = User.followers(user_snippet.id)
    followers.each do |follower|
      ActionController::Base.new.expire_cell_state UserCell, :sidebar, follower.id.to_s
    end
  end

  class << self
    def current_post(user)
      where(:created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))), 'user_snippet._id' => user.id, :current => true).first
    end

    def following_feed(user, feed_filters, include_self = false)
      where(
              :created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))),
              'user_snippet._id' => {'$in' => (include_self ? user.following_users << user.id : user.following_users)},
              :current => true,
              :night_type.in => feed_filters[:display]
      ).order_by(feed_filters[:sort][:target], feed_filters[:sort][:order])
    end

    def list_feed(users)
      where(
              :created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))),
              'user_snippet._id' => {'$in' => users},
              :current => true
      ).order_by(:created_at, 'desc')
    end

    def following(user)
      where('user_snippet._id' => {'$in' => user.following_users})
    end

    def todays_post
      where(:created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))), :current => true)
    end

    def convert_for_api(post)
      {
              :id => post.id,
              :comment_count => post.comment_count,
              :comments => Comment.convert_for_api(post.comments),
              :votes_count => post.votes,
              :created_at => post.created_at,
              :night_type => post.night_type,
              :created_by => UserSnippet.convert_for_api(post.user_snippet),
              :tag => Tag.convert_for_api(post.tag),
              :venue => Venue.convert_for_api(post.venue),
              :voters => post.voters.map{|v| UserSnippet.convert_for_api(v)}
      }
    end
  end

end
