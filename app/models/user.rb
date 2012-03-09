require "whoot"

class User
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Whoot::Images
  include SoulmateHelper
  include Rails.application.routes.url_helpers


  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable

  field :username
  field :first_name
  field :last_name

  slug :username

  field :gender
  field :status, :default => 'Active'
  field :birthday, :type => Date
  field :time_zone, :type => String, :default => "Eastern Time (US & Canada)"

  field :roles, :default => []
  field :following_users_count, :type => Integer, :default => 0
  field :following_users, :default => []
  field :followers_count, :type => Integer, :default => 0
  field :unread_notification_count, :type => Integer, :default => 0
  field :pings_today_date
  field :pings_today, :default => []
  field :pings_count, :type => Integer, :default => 0
  field :pings_sent_today, :default => 0
  field :votes_count, :default => 0
  field :invited_emails, :default => []
  field :last_invite_time
  field :device_token
  field :device_type
  field :race_score, :default => 0

  auto_increment :public_id

  index :public_id
  index :slug
  index(
          [
                  [ :_id, Mongo::ASCENDING ],
                  ["current_post", Mongo::ASCENDING],
                  [:first_name, Mongo::ASCENDING],
                  [:last_name, Mongo::ASCENDING]
          ]
  )
  index "social_connects"
  index(
          [
                  [:following_users, Mongo::ASCENDING],
                  [:first_name, Mongo::ASCENDING],
                  [:last_name, Mongo::ASCENDING]
          ]
  )
  index(
          [
                  [:_id, Mongo::ASCENDING],
                  [:first_name, Mongo::ASCENDING],
                  [:last_name, Mongo::ASCENDING]
          ]
  )
  index :email
  index :roles
  index :invited_emails

  embeds_many :social_connects
  embeds_many :schools, :class_name => 'School'
  embeds_one :current_post, :as => :post_assignable, :class_name => 'PostSnippet'
  embeds_one :location, as: :has_location, :class_name => 'LocationSnippet'
  embeds_one :settings, :class_name => 'UserSettings'
  has_many :tags
  has_many :lists
  has_many :notifications
  has_many :pings
  has_many :venues
  has_many :posts

  validates :email, :first_name, :last_name, :gender, :presence => true
  validates :gender, :inclusion => { :in => ["m", "f"], :message => "Please enter a valid gender." }
  validates :email, :uniqueness => { :case_sensitive => false }
  attr_accessible :first_name, :last_name, :gender, :birthday, :email, :password, :password_confirmation, :remember_me, :social_connected
  attr_accessor :current_ip

  before_create :generate_username, :set_settings, :set_location_snippet
  after_create :save_profile_image, :send_welcome_email, :update_invites, :notify_friends
  before_destroy :remove_from_soulmate
  before_save :add_to_soulmate

  scope :inactive, where(:last_sign_in_at.lte => Chronic.parse('1 month ago'))

  # Return the users slug instead of their ID
  def to_param
    "#{encoded_id}-#{fullname.parameterize}"
  end

  def generate_username
    self.username = "#{first_name.downcase}.#{last_name.downcase}"
  end

  # TODO: dont think this is in use, double check
  def set_location_snippet
    my_location = Geocoder.address(Rails.env.development? ? '75.69.89.109' : current_sign_in_ip)
    if my_location
      found_location = City.near(my_location).first
    end
    unless defined?(found_location) && found_location
      found_location = City.where(name: "New York City").first
    end
    set_location(found_location)
  end

  def set_location(new_location)
    snippet = LocationSnippet.new(
            city: new_location.name,
            state_code: new_location.state_code,
            coordinates: new_location.coordinates
    )
    snippet.id = new_location.id
    self.location = snippet
  end

  def set_settings
    self.settings = UserSettings.new
  end

  def toggle_setting(setting)
    case setting
      when 'email_comment'
        self.settings.email_comment = !settings.email_comment
      when 'email_ping'
        self.settings.email_ping = !settings.email_ping
      when 'email_follow'
        self.settings.email_follow = !settings.email_follow
      when 'email_daily'
        self.settings.email_daily = !settings.email_daily
    end
  end

  # Pull image from social media, or gravatar
  def save_profile_image
    hash = Digest::MD5.hexdigest(email.downcase)+'.jpeg'
    facebook = get_social_connect 'facebook'

    image_url = if facebook
                  "http://graph.facebook.com/#{facebook.uid}/picture?type=large"
                else
                  "http://www.gravatar.com/avatar/#{hash}?s=500&d=monsterid"
                end

    writeOut = open("/tmp/#{hash}", "wb")
    writeOut.write(open(image_url).read)
    writeOut.close

    image = self.images.create(:user_id => id)
    version = AssetImage.new(:isOriginal => true)
    version.id = image.id
    version.image.store!("/tmp/#{hash}")
    image.versions << version
    version.save
    self.save
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver
  end

  def update_invites
    inviters = User.where(:invited_emails => email)
    inviters.each do |inviter|
      self.follow_user(inviter)
      inviter.follow_user(self)
      inviter.save
    end
    self.save
  end

  def follow_admins
    admins = User.where(:roles => 'admin')
    admins.each do |admin|
      follow_user(admin)
      admin.save
    end
    self.save
  end

  def fullname
    "#{self.first_name} #{self.last_name}"
  end

  # Checks to see if this user has a given role
  def role?(role)
    roles.include? role
  end

  # Adds a role to this user
  def grant_role(role)
    roles << role unless roles.include?(role)
  end

  # Removes a role from this user
  def revoke_role(role)
    if roles
      self.roles.delete(role)
    end
  end

  def following_user?(user_id)
    following_users.include? user_id
  end

  def toggle_follow_user(user)
    if following_user? user.id
      unfollow_user user
    else
      follow_user user
    end
  end

  def follow_user(user)
    if !following_users.include?(user.id)
      follow = Follow.following(id, user.id)
      unless follow
        follow = Follow.new(
                :from_user_id => id,
                :to_user_id => user.id
        )
      end

      Notification.add(user, :follow, (user.settings.email_follow ? true : false), self, [Chronic.parse('today at 12:01am'), Chronic.parse('today at 11:59pm')])
      follow.active = true
      follow.save

      self.following_users << user.id
      self.following_users_count += 1
      user.followers_count += 1
      Resque.enqueue(SmUserFollowUser, id.to_s, user.id.to_s)

      user.race_score += 1 if created_at > Chronic.parse('March 1, 2012')
    end
  end

  def unfollow_user(user)
    if following_users.include?(user.id)
      follow = Follow.following(id, user.id)
      unless follow
        follow = Follow.new(
                :from_user_id => id,
                :to_user_id => user.id
        )
      end
      Notification.remove(user, :follow, self, nil, nil)
      follow.active = false
      follow.save

      self.following_users.delete(user.id)
      self.following_users_count -= 1
      user.followers_count -= 1
      Resque.enqueue(SmUserUnfollowUser, id.to_s, user.id.to_s)

      user.race_score -= 1 if created_at > Chronic.parse('March 1, 2012')
    end
  end

  def pinged_today_by?(user_id)
    pings_today_date && pings_today_date >= Post.cutoff_time && pings_today.include?(user_id)
  end

  def add_ping(user)
    unless pinged_today_by? user.id
      unless pings_today_date && pings_today_date >= Post.cutoff_time
        self.pings_today_date = Time.now
        self.pings_today = Array.new
      end
      Ping.create(:pinged_user_id => id, :user_id => user.id)
      self.pings_today << user.id
      self.pings_count += 1
      user.pings_sent_today += 1
    end
  end

  def posted_today?
    current_post && current_post.created_at >= Post.cutoff_time
  end

  def gender_pronoun
    if gender == 'm' then 'he' elsif gender == 'f' then 'she' else 'they' end
  end

  def gender_him_her
    if gender == 'm' then 'him' elsif gender == 'f' then 'her' else 'them' end
  end

  def gender_possesive
    if gender == 'm' then 'his' elsif gender == 'f' then 'her' else 'their' end
  end

  def invited?(email)
    invited_emails.include? email
  end

  def add_invited_email(email)
    email.strip!
    unless email =~ /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i
      errors.add(:invited_emails, "Please enter a valid email.")
    else
      if invited?(email)
        errors.add(:invited_emails, "You have already invited this email.")
      elsif last_invite_time && Time.now - last_invite_time <= 10
        errors.add(:invited_emails, "Please wait at least 10 seconds before inviting another friend.")
      else
        target = User.where(:email => email).first
        if target
          errors.add(:invited_emails, "This email is already registered on The Whoot.")
        else
          self.invited_emails << email
          self.last_invite_time = Time.now
        end
      end
    end
  end

  def get_social_connect provider
    social_connects.each do |social|
      return social if social.provider == provider
    end
    nil
  end


  def facebook
    connection = social_connects.detect{|connection| connection.provider == 'facebook'}
    if connection
      @fb_user ||= Koala::Facebook::API.new(connection.token)
    else
      nil
    end
  end

  def twitter
    provider = get_social_connect('twitter')
    if provider
      Twitter.configure do |config|
        config.consumer_key = ENV['TWITTER_KEY']
        config.consumer_secret = ENV['TWITTER_SECRET']
        config.oauth_token = provider.token
        config.oauth_token_secret = provider.secret
      end
      @twitter ||= Twitter.new
    else
      nil
    end
  end

  def add_to_soulmate
    if new_record?
      Resque.enqueue(SmCreateUser, id.to_s)
    end
  end

  def remove_from_soulmate
    Resque.enqueue(SmDestroyUser, id.to_s)
  end

  def encoded_id
    public_id.to_i.to_s(36)
  end

  def notify_friends
    Resque.enqueue_in(1.minutes, NotifyFriends, id.to_s)
  end

  # Basic data for mixpanel
  def mixpanel_data
    {
            'User ID' => id.to_s,
            'Birthday' => (birthday ? birthday : nil),
            'Gender' => (gender ? gender : nil),
            'Following Count' => following_users_count,
            'Followers Count' => followers_count,
            'Pings Count' => pings_count,
            'Votes Count' => votes_count,
            'Device Type' => device_type,
            'School' => (primary_school ? primary_school.name : nil),
            'School Type' => (primary_school ? primary_school.type : nil)
    }
  end

  def primary_school
    found = nil
    schools.each do |school|
      if ['College', 'University'].include?(school.type)
        found = school
      elsif found == nil
        found = school
      end
    end
    found
  end

  def add_school(data)
    found = schools.detect  {|s| s.fb_id ==  data[:fb_id] }
    unless found
      self.schools.new(data)
    end
  end

  class << self
    def find_by_encoded_id(id)
      where(:public_id => id.to_i(36)).first
    end

    def undecided(user)

      or_criteria = []
      or_criteria << {"current_post.created_at" => { "$lt" => Post.cutoff_time.utc }}
      or_criteria << {:current_post => {"$exists" => false}}

      where(:_id.in => user.following_users).any_of(or_criteria)
    end

    def followers(user_id)
      where(:following_users => user_id).order_by([[:first_name, :asc], [:last_name, :desc]])
    end

    # Omniauth providers
    def find_by_omniauth(omniauth, signed_in_resource=nil, mixpanel=nil, input=nil)
      info = omniauth['info']
      extra = omniauth['extra']['raw_info']

      if signed_in_resource
        user = signed_in_resource
      else
        user = User.where("social_connects.uid" => omniauth['uid'], 'social_connects.provider' => omniauth['provider']).first
      end

      # Try to get via email if user not found and email provided
      unless user || !info['email']
        user = User.where(:email => info['email']).first
      end

      # If we found the user, update their token
      if user
        new_user = false
        connect = user.social_connects.detect{|connection| connection.uid == omniauth['uid'] && connection.provider == omniauth['provider']}
        # Is this a new connection?
        unless connect
          connect = SocialConnect.new(:uid => omniauth["uid"], :provider => omniauth['provider'])
          connect.secret = omniauth['credentials']['secret'] if omniauth['credentials'].has_key?('secret')
          user.social_connects << connect
        end
        # Update the token
        connect.token = omniauth['credentials']['token']
      else # Create a new user with a stub password.
        new_user = true
        if extra["gender"]
          gender = extra["gender"] == 'male' ? 'm' : 'f'
        else
          gender = nil
        end
        user = User.new(
                first_name: extra["first_name"], last_name: extra["last_name"],
                gender: gender, email: info["email"], password: Devise.friendly_token[0,20]
        )
        user.birthday = Chronic.parse(extra["birthday"]) if extra["birthday"]
        user.social_connects << SocialConnect.new(:uid => omniauth["uid"], :provider => omniauth['provider'], :token => omniauth['credentials']['token'])
      end

      # Update schools if the user doesn't have them yet
      if extra['education'] && extra['education'].length > 0 && (!user.schools || user.schools.length == 0)
        extra['education'].each do |e|
          data = {:type => e['type']}
          if e['school']
            data[:fb_id] = e['school']['id']
            data[:name] = e['school']['name']
          end
          if e['year']
            data[:year] = e['year']['name']
          end

          user.schools.new(data)
        end
      end

      user.save

      if mixpanel && new_user == true
        mixpanel.track_event("User Signup", {:format => input}.merge!(user.mixpanel_data))
      end

      user
    end

    # Fetchs all the users for an array of objects from the DB
    # Loops through the objects and attaches it's user to the :created_at key
    # Returns objects with their user info joined on
    def join(objects)
      user_ids = objects.map{|object| object.user_id}
      users = User.where(:_id.in => user_ids)
      joined = objects.map do |object|
        object[:created_by] = users.detect {|u| u.id == object.user_id}
        object
      end

      joined
    end

    def convert_for_api(user, current_user=nil)
      data = {
              :id => user.id,
              :first_name => user.first_name,
              :last_name => user.last_name,
              :current_post => Post.convert_for_api(Post.current_post(user)),
              :email => user.email,
              :public_id => user.encoded_id,
              :vote_count => user.votes_count.to_i,
              :ping_count => user.pings_count.to_i,
              :following_users_count => user.following_users_count.to_i,
              :followers_count => user.followers_count.to_i
      }
      data[:is_following] = current_user.following_users.include?(user.id) if current_user
      data[:has_pinged] = user.pinged_today_by?(current_user.id) if current_user
      data
    end
  end
end

