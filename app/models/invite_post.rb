require "whoot"

class InvitePost < Post
  include Whoot::Images

  field :content
  field :time
  field :attending_count, :default => 0
  field :attendees, :default => []

  auto_increment :public_id

  index [[:attending_count, Mongo::DESCENDING]], :sparse => true
  index :public_id, :sparse => true

  embeds_one :user_snippet, as: :user_assignable

  validates :content, :length => { :in => 0..500, :message => "Description must be less than 500 characters" }
  validates :time, :length => { :in => 1..30, :message => "Start time must be between 1 and 30 characters" }
  validate :venue_fields

  attr_accessible :content, :time

  before_create :set_user_snippet
  after_create :create_linked_normal_post

  def to_param
    "#{self.public_id.to_i.to_s(36)}-#{self.venue.name}"
  end

  def set_user_snippet
    self.user_snippet = UserSnippet.new(
            :username => user.username,
            :first_name => user.first_name,
            :last_name => user.last_name,
            :public_id => user.public_id
    )
  end

  def venue_fields
    if @venue_id == '' && (venue.name.length < 3 || venue.name.length > 75)
      errors.add(:venue_name, "Venue name must be between 3 and 75 characters")
    end

    if @venue_id == '' && (venue.address.length < 5 || venue.address.length > 140)
      errors.add(:venue_address, "Venue address must be between 5 and 140 characters")
    end
  end

  def create_linked_normal_post
    add_attending(user)
  end

  def add_attending(user)
    unless attendees.include? user.id
      current_post = NormalPost.current_post user
      post = NormalPost.where(:user_id => user.id, :invite_post_id => id).first
      unless post
        post = user.normal_posts.new(
                :night_type => night_type,
                :invite_post_id => id,
                :venue_id => venue.id,
                :venue => venue.attributes
        )
      end

      if (current_post)
        current_post.current = false
        current_post.save
      end
      post.current = true
      post.status = 'Active'

      if post.save
        self.attending_count += 1
        self.attendees << user.id
        self.save
      end
    end
  end

  def remove_attending(user)
    if attendees.include? user.id
      current_post = NormalPost.current_post user
      user.revert_to_last_post_today
      if (current_post)
        current_post.current = false
        current_post.save
      end
      self.attending_count -= 1
      self.attendees.delete user.id
      self.save
    end
  end

  def attending?(user)
    if attendees and attendees.include? user.id then true else nil end
  end

  def cancel
    self.status = 'Cancelled'
    self.current = false
    revert_attending_users
  end

  # Loop through all attending users and set their post to their last active post
  def revert_attending_users
    users = User.where(:_id.in => attendees)
    users.each do |user|
      current_post = NormalPost.current_post user
      user.revert_to_last_post_today
      if (current_post)
        current_post.current = false
        current_post.save
      end
    end
    NormalPost.where(:invite_post_id => id).update_all(:status => 'Cancelled')
  end

  class << self
    def find_by_encoded_id(id)
      where(:public_id => id.to_i(36)).first
    end

    def following_feed(user, feed_filters)
      following = user.following_users.dup
      following << user.id
      where(
              :user_id.in => following,
              :current => true,
              :created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))),
              :night_type.in => feed_filters[:display]
      ).order_by(feed_filters[:sort][:target], feed_filters[:sort][:order])
    end
  end

end