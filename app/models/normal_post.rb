class NormalPost < Post

  field :votes, :default => 0
  field :voters, :default => []
  field :invite_post_id

  index [[:votes, Mongo::DESCENDING]], :sparse => true

  embeds_many :tags, :as => :taggable, :class_name => 'TagSnippet'
  embeds_one :invite, :as => :has_invite, :class_name => 'InvitePostSnippet'
  belongs_to :invite_post

  validate :max_tags, :max_characters

  after_save :update_user_post_snippet
  before_create :process_tags, :disable_current_post, :set_user_post_snippet, :set_invite_post_snippet

  attr_accessible :invite_post_id

  def invite_url
    if invite_post_id
      "#{invite.public_id.to_i.to_s(36)}-#{venue.name}"
    end
  end

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
      if current_post.invite_post
        invite = current_post.invite_post
        invite.attending_count -= 1
        invite.attendees.delete user_id
        invite.save
      end
    end
  end

  def set_user_post_snippet
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

  def update_user_post_snippet
    if current_changed? && current == true
      user.current_post = PostSnippet.new(:night_type => night_type, :created_at => created_at)
      user.save
    end
  end

  def set_invite_post_snippet
    if invite_post
      snippet = InvitePostSnippet.new(
              :public_id => invite_post.public_id
      )
      snippet.id = invite_post.id
      self.invite = snippet
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
  end

end