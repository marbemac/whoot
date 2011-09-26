require "whoot"

class InvitePost < Post
  include Whoot::Images

  field :content
  field :time
  field :attending_count, :default => 0
  field :attendees, :default => []

  auto_increment :_public_id

  embeds_one :user_snippet, as: :user_assignable

  validates :content, :length => { :in => 0..500, :message => "Description must be less than 500 characters" }
  validates :time, :length => { :in => 1..30, :message => "Start time must be between 1 and 30 characters" }
  validate :venue_fields

  attr_accessible :content, :time

  before_create :set_user_snippet
  after_create :create_linked_normal_post

  def to_param
    "#{self._public_id.to_i.to_s(36)}-#{self.venue.name}"
  end

  def set_user_snippet
    self.user_snippet = UserSnippet.new(
            :username => user.username,
            :first_name => user.first_name,
            :last_name => user.last_name,
            :_public_id => user._public_id
    )
  end

  def venue_fields
    if venue.name.length < 3 || venue.name.length > 75
      errors.add(:venue_name, "Venue name must be between 3 and 75 characters")
    end

    if venue.address.length < 5 || venue.address.length > 140
      errors.add(:venue_address, "Venue address must be between 5 and 140 characters")
    end
  end

  def create_linked_normal_post
    add_attending(user)
  end

  def add_attending(user)
    unless attendees.include? user.id
      post = user.normal_posts.new(
              :night_type => night_type,
              :invite_post_id => id,
              :venue => {
                      :name => venue.name,
                      :address => venue.address,
                      :coordinates => venue.coordinates
              }
      )
      post.venue.id = venue.id

      if post.save
        self.attending_count += 1
        self.attendees << user.id
        self.save
      end
    end
  end

  def remove_attending(user)
    if voters.include? user.id
      self.votes -= 1
      self.voters.delete user.id
    end
  end

  def has_attending?(user)
    if voters and voters.include? user.id then true else nil end
  end

  class << self
    def find_by_encoded_id(id)
      where(:_public_id => id.to_i(36)).first
    end

    def following_feed(user, feed_filters)
      following = user.following_users << user.id
      where(
              :user_id.in => following,
              :current => true,
              :created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))),
              :night_type.in => feed_filters[:display]
      ).order_by(feed_filters[:sort][:target], feed_filters[:sort][:order])
    end
  end

end