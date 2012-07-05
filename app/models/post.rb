class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include ModelUtilitiesHelper

  field :status, :default => 'Active'
  field :current, :default => true
  field :night_type
  field :comment_count, :default => 0
  field :votes, :default => 0
  field :address_original
  field :entry_point
  field :suggestions
  field :tag
  field :shouted, :default => false

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
  embeds_one :user_snippet, :as => :user_assignable, :class_name => 'UserSnippet'
  embeds_many :voters, :as => :user_assignable, :class_name => 'UserSnippet'
  embeds_many :post_events, :class_name => 'PostEvent'

  validates :night_type, :inclusion => { :in => ["working", "low_in", "low_out", "big_out"], :message => "Please select a post type below! (working, staying in, relaxing out, or partying)" }
  validate :max_characters
  attr_accessible :night_type, :tag, :address_original, :venue, :suggestions
  attr_accessor :user_id, :address_placeholder
  belongs_to :user, :foreign_key => 'user_snippet.id'

  after_create :send_ping_updates, :reset_pings_sent
  before_save :set_venue_snippet, :update_post_event, :set_user_location_by_venue, :set_location_snippet, :set_user_post_snippet

  def max_characters
    if tag && !tag? && tag.length > 40
      errors.add(:tags, "You can only use 40 characters for your tag! You tag has #{tag.length} characters.")
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
    if user.location && user.location != location
      self.location = user.location
    end
  end

  def update_post_event
    if !persisted? || (persisted? && (night_type_changed? || address_original_changed? || (tag_changed?) || (venue && venue.name_changed?)))
      event = PostChangeEvent.new(:night_type => night_type)
      if has_venue?
        if venue
          event.venue_id = venue.id
          event.venue_public_id = venue.public_id
        end
        event.venue_name = venue_pretty_name
      end

      event.tag = tag if tag

      event.created_at = Time.now
      self.created_at = Time.now
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
          Notification.send_push_notification(u.device_token, u.device_type, text, u.unread_notification_count, user_id)
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
          target_venue.save
        end
      end

      if target_venue
        self.venue = nil
        new_venue = VenueSnippet.new(
                :name => target_venue.name,
                :public_id => target_venue.public_id,
                :coordinates => target_venue.coordinates
        )
        new_venue.address = target_venue.address
        new_venue.id = target_venue.id
        self.venue = new_venue
      elsif !venue || !venue.address
        self.venue = nil
      end
    else
      self.venue = nil
    end
  end

  def add_voter(user)
    if user.id == user_snippet.id
      false
    else
      unless has_voter?(user)
        self.votes += 1
        snippet = UserSnippet.new(
                :username => user.username,
                :first_name => user.first_name,
                :last_name => user.last_name,
                :public_id => user.public_id,
                :fbuid => user.fbuid
        )
        snippet.id = user.id
        self.voters << snippet
        #event = PostLoopEvent.new(:user_snippet => snippet)
        #event.id = user.id
        #self.post_events << event
        #self.user.votes_count += 1
        #self.user.save
      end
      true
    end
  end

  def remove_voter(user)
    if has_voter?(user)
      self.votes -= 1
      voter = self.voters.find(user.id)
      voter.delete
    end
  end

  def has_venue?
    !address_original.blank?
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

  def set_user_location_by_mobile(lat, long)
    city = City.near([lat.to_f, long.to_f], 30).first
    city = City.where(:name => "Elsewhere").first unless city
    set_user_location(city)
  end

  def set_user_location_by_venue
    if !address_original.blank? && address_original_changed? && venue && venue.coordinates
      city = City.near(venue.coordinates.reverse, 30).first
      city = City.where(:name => "Elsewhere").first unless city
    end
    set_user_location(city)
  end

  def set_user_location(city)
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

  def send_ping_updates
    # Send emails to the users that pinged this user
    unless user.posted_today? || !user.pings_today_date || user.pings_today_date <= Post.cutoff_time
      users = User.where(:_id.in => user.pings_today)
      users.each do |to_user|
        if to_user.device_token
          Notification.send_push_notification(to_user.device_token, to_user.device_type, "#{user.first_name} posted what #{user.gender_pronoun}'s up to tonight!", to_user.unread_notification_count, user.id)
        else
          PingMailer.pinged_user_posted(user.id.to_s, to_user.id.to_s).deliver
        end
      end
    end
  end

  def set_user_post_snippet
    if created_at >= Post.cutoff_time
      post_snippet = PostSnippet.new(
              :night_type => night_type,
              :created_at => created_at ? created_at : Time.now
      )
      post_snippet.suggestions = suggestions
      post_snippet.address_original = address_original
      post_snippet.tag = tag
      post_snippet.venue = venue
      post_snippet.comment_count = comment_count
      post_snippet.loop_in_count = votes
      post_snippet.id = id
      user.current_post = post_snippet
      user.save
    end
  end

  def set_user_snippet(user)
    self.user_snippet = UserSnippet.new(
            :username => user.username,
            :first_name => user.first_name,
            :last_name => user.last_name,
            :public_id => user.public_id,
            :fbuid => user.fbuid,
            :gender => user.gender
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
      snippet = UserSnippet.new(
              :username => user.username,
              :first_name => user.first_name,
              :last_name => user.last_name,
              :public_id => user.public_id,
              :fbuid => user.fbuid
      )
      snippet.id = user.id
      event = PostCommentEvent.new(:user_snippet => snippet, :comment => comment)
      event.id = comment.id
      self.post_events << event
      self.comment_count += 1
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
    if tag && !tag.blank?
      text += " - #{tag}"
    end
    if has_venue?
      text += " (#{venue_pretty_name})"
    end
    text += ". What's everyone else up to? @TheWhoot TheWhoot.com"
    text
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

  def shout(shout_text, user)
    if shouted
      false
    else
      snippet = UserSnippet.new(
          :username => user.username,
          :first_name => user.first_name,
          :last_name => user.last_name,
          :public_id => user.public_id,
          :fbuid => user.fbuid
      )
      snippet.id = user.id
      event = PostShoutEvent.new(:user_snippet => snippet, :content => shout_text)
      self.post_events << event
      self.shouted = true
      event
    end
  end

  def as_json(current_user, options={})
    data = {
            :id => id.to_s,
            :tag => tag,
            :night_type => night_type,
            :night_type_noun => night_type_noun,
            :night_type_short => night_type_short,
            :comment_count => comment_count,
            :loop_in_count => votes,
            :address_original => address_original,
            :venue => venue.as_json,
            :location => location,
            :created_at => created_at,
            :created_at_pretty => pretty_time(created_at),
            :created_at_day => pretty_day(created_at),
            :suggestions => suggestions,
            :user => user_snippet.as_json,
            :events => post_events.map{|e| e.as_json unless e.user_snippet && current_user.blocked_by.include?(e.user_snippet.id) }.compact,
            :loop_ins => voters.map {|v| v.as_json}
    }

    data
  end

  class << self
    def current_post(user)
      where('user_snippet._id' => user.id, :created_at.gte => Post.cutoff_time, :current => true).first
    end

    def following_feed(user, include_self = false)
      where(
              :created_at.gte => Post.cutoff_time,
              'user_snippet._id' => {'$in' => (include_self ? user.following_users << user.id : user.following_users)},
              :current => true
      )
    end

    def city_feed(user)
      where(
              :created_at.gte => Post.cutoff_time,
              'location._id' => user.location.id,
              :current => true
      )
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

    def analytics(posts)
      data = {}
      [:working, :low_in, :low_out, :big_out].each do |type|
        typed_posts = posts.where(:night_type => type)
        data[type] = {
            :now => (typed_posts.count.to_f / posts.count.to_f * 100).to_i,
            :change => 0,
            :male => (typed_posts.where("user_snippet.gender" => "m").count.to_f / posts.count.to_f * 100).to_i,
            :female => (typed_posts.where("user_snippet.gender" => "f").count.to_f / posts.count.to_f * 100).to_i
        }
      end
      data
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
                :tag => post.tag ? {:id => nil, :name => post.tag} : nil,
                :venue => Venue.convert_for_api(post.venue),
                :voters => post.voters.map{|v| UserSnippet.convert_for_api(v)},
                :shouted => shouted ? shouted : false
        }
      else
        nil
      end
    end
  end

end
