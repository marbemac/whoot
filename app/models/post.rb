class Post
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :status, :default => 'Active'
  field :current, :default => true
  field :night_type
  field :comment_count, :default => 0
  field :votes, :default => 0
  field :address_original
  field :entry_point

  index(
          [
                  ["user_snippet", Mongo::ASCENDING],
                  [ :created_at, Mongo::DESCENDING ]
          ]

  )
  index "post_events._id"
  index(
          [
                  ["venue_snippet", Mongo::ASCENDING],
                  ["user_snippet", Mongo::ASCENDING],
          ]
  )
  #index [["venue.coordinates", Mongo::GEO2D]], :min => -180, :max => 180
  #index [["location.coordinates", Mongo::GEO2D]], :min => -180, :max => 180

  embeds_one :venue, :as => :has_venue, :class_name => 'VenueSnippet'
  embeds_one :location, as: :has_location, :class_name => 'LocationSnippet'
  embeds_one :tag, :as => :taggable, :class_name => 'TagSnippet'
  embeds_one :user_snippet, :as => :user_assignable, :class_name => 'UserSnippet'
  embeds_many :voters, :as => :user_assignable, :class_name => 'UserSnippet'
  embeds_many :post_events, :class_name => 'PostEvent'

  validates :night_type, :inclusion => { :in => ["working", "low_in", "low_out", "big_out"], :message => "Please select a post type below! (working, staying in, relaxing out, or partying)" }
  validate :max_characters
  attr_accessible :night_type, :venue, :tag, :address_original
  attr_accessor :user_id, :address_placeholder
  belongs_to :user, :foreign_key => 'user_snippet.id'

  after_create :set_user_post_snippet, :reset_pings_sent
  before_save :set_venue_snippet, :update_post_event
  after_save :set_location_snippet, :set_user_location, :process_tag, :clear_caches

  def max_characters
    if tag && tag.name.length > 40
      errors.add(:tags, "You can only use 40 characters for your tag! You tag has #{tag.name.length} characters.")
    end
  end

  def night_type_short(text=nil)
    names = {:working => "Working", :low_in => "Staying In", :low_out => "Relaxing Out", :big_out => "Partying"}
    names[text ? text : night_type.to_sym]
  end

  def night_type_noun
    names = {:working => "Work", :low_in => "Stay In", :low_out => "Relax Out", :big_out => "Party"}
    names[night_type.to_sym]
  end

  def created_by
    self[:created_by]
  end

  def set_location_snippet
    if user.location
      self.location = LocationSnippet.new(
        user.location.attributes
      )
    end
  end

  def update_post_event
    if !persisted? || (persisted? && (night_type_changed? || address_original_changed? || (tag && tag.name_changed?) || (venue && venue.name_changed?)))
      event = PostChangeEvent.new(:night_type => night_type)
      if has_venue?
        if venue
          event.venue_id = venue.id
          event.venue_public_id = venue.public_id
        end
        event.venue_name = venue_pretty_name
      end

      if tag
        event.tag = tag.name
      end

      event.created_at = Time.now
      self.post_events << event
    end
  end

  def update_loop
    old_post = Post.where('user_snippet._id' => user_snippet.id, :created_at.gte => Post.cutoff_time).order_by(:created_at, :desc).skip(1).first
    if old_post
      old_post.current = false
      old_post.save
      self.votes = old_post.votes
      self.voters = old_post.voters
      save

      # notify people in this loop
      notify_users = User.where(:_id => {"$in" => voters.map{|v| v.id}})
      text = "#{user_snippet.first_name} is #{night_type_short}"
      if has_venue?
        text += " at #{venue_pretty_name}"
      end
      notify_users.each do |u|
        if u.device_token
          Notification.send_push_notification(u.device_token, u.device_type, text)
        end
      end
    end
  end

  def set_venue_snippet
    if has_venue?
      target_venue = nil
      if venue && !venue.address_string.blank?
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
    else
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
      event = PostLoopEvent.new(:user_snippet => snippet)
      self.post_events << event
      self.user.votes_count += 1
      self.user.save
      clear_post_cache
    end
  end

  def has_venue?
    !address_original.blank? || venue
  end

  def venue_pretty_name
    if !address_original.blank? && (!venue || venue.name.blank?)
      address_original
    else
      venue.pretty_name
    end
  end

  def has_voter?(user)
    voters.detect{|v| v.id == user.id}
  end

  def set_user_location
    if !address_original.blank? && address_original_changed? && venue
      city = City.near(venue.coordinates.reverse).first
      if city && city.id != user.location.id
        snippet = LocationSnippet.new(
                city: city.name,
                state_code: city.state_code,
                coordinates: city.coordinates
        )
        snippet.id = city.id
        user.location = snippet
        user.save
      end
    end
  end

  def process_tag
    if self.valid? && tag && !tag.name.blank?
      if tag.name_changed?
        found = Tag.where(:slug => tag.name.to_url).first
        if found
          found.score += 1
          found.save
        else
          found = user.tags.create(name: tag.name)
        end
        tag.id = found.id
      end
      tag
    else
      self.tag = nil
    end
  end

  def set_user_post_snippet
    # Send emails to the users that pinged this user
    unless user.posted_today? || !user.pings_today_date || user.pings_today_date <= Post.cutoff_time
      users = User.where(:_id.in => user.pings_today)
      users.each do |to_user|
        if to_user.device_token
          Notification.send_push_notification(to_user.device_token, to_user.device_type, "#{user.first_name} posted what #{user.gender_pronoun}'s up to tonight!")
        else
          PingMailer.pinged_user_posted(user, to_user).deliver
        end
      end
    end
    post_snippet = PostSnippet.new(
            :night_type => night_type,
            :created_at => created_at
    )
    post_snippet.tag = tag
    post_snippet.venue = venue
    user.current_post = post_snippet
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

  def comments
    post_events.select{|pe| pe._type == "PostCommentEvent"}.map{|pe| pe.comment}
  end

  def find_comment(cid)
    event = post_events.where("comment._id" => BSON::ObjectId(cid)).first
    event ? event.comment : nil
  end

  def add_comment(data, user)
    comment = Comment.new(data)
    comment.set_user_snippet(user)
    if comment.valid?
      event = PostCommentEvent.new(:comment => comment)
      event.id = comment.id
      self.post_events << event
      self.comment_count += 1
      clear_post_cache
      save
    end
    comment
  end

  def remove_comment(comment)
    comment._parent.destroy
    self.comment_count -= 1
    save
  end

  def user
    User.find(user_snippet.id)
  end

  def tweet_text
    text = "I'm #{night_type_short} tonight"
    if tag && !tag.name.blank?
      text += " - #{tag.name}"
    end
    if has_venue?
      text += " (#{venue_pretty_name})"
    end
    text += ". What's everyone else up to? @TheWhoot TheWhoot.com"
    text
  end

  def clear_caches
    clear_post_cache
  end

  def clear_post_cache
    ActionController::Base.new.expire_fragment("#{id.to_s}-teaser")
    ActionController::Base.new.expire_fragment("#{id.to_s}-teaser-mine")
    ActionController::Base.new.expire_fragment("#{id.to_s}-teaser-voted")
  end

  def teaser_cache_key(user)
    key = "#{id.to_s}-teaser"
    if user_snippet.id == user.id
      key += '-mine'
    elsif has_voter?(user)
      key += '-voted'
    end
    key
  end

  # converts events for the api
  def api_events
    data = []
    post_events.each do |event|
      data << {
        :id => event.id,
        :content => event.api_text,
        :created_at => event.created_at,
        :created_by => UserSnippet.convert_for_api(event.user)
      }
    end
    data
  end

  def reset_pings_sent
    user.set(:pings_sent_today, 0)
  end

  class << self
    def current_post(user)
      where('user_snippet._id' => user.id, :created_at.gte => Post.cutoff_time, :current => true).first
    end

    def following_feed(user, feed_filters, include_self = false)
      where(
              :created_at.gte => Post.cutoff_time,
              'user_snippet._id' => {'$in' => (include_self ? user.following_users << user.id : user.following_users)},
              :current => true,
              :night_type.in => feed_filters[:display]
      ).order_by(feed_filters[:sort][:target], feed_filters[:sort][:order])
    end

    def list_feed(users)
      where(
              :created_at.gte => Post.cutoff_time,
              'user_snippet._id' => {'$in' => users},
              :current => true
      ).order_by(:created_at, 'desc')
    end

    def following(user)
      where('user_snippet._id' => {'$in' => user.following_users})
    end

    def todays_post
      where(:created_at.gte => Post.cutoff_time, :current => true)
    end

    def cutoff_time
      Chronic.parse('today at 5:00am', :now => Chronic.parse('5 hours ago'))
    end

    def convert_for_api(post)
      if post
        {
                :id => post.id,
                :comment_count => post.comment_count,
                :comments => post.api_events,
                :votes_count => post.votes,
                :created_at => post.created_at,
                :night_type => post.night_type,
                :created_by => UserSnippet.convert_for_api(post.user_snippet),
                :tag => Tag.convert_for_api(post.tag),
                :venue => Venue.convert_for_api(post.venue),
                :voters => post.voters.map{|v| UserSnippet.convert_for_api(v)}
        }
      else
        nil
      end
    end
  end

end
