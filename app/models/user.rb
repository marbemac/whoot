require "whoot"

class User
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Whoot::Images


  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable

  # Denormalized:
  # InvitePost.user_snippet.name
  field :username

  # Denormalized:
  # InvitePost.user_snippet.first_name
  field :first_name

  # Denormalized:
  # InvitePost.user_snippet.last_name
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
  field :votes_count, :default => 0
  field :invited_emails, :default => []
  field :last_invite_time

  auto_increment :public_id

  index :public_id
  index :email
  index :current_post
  index [["current_post.created_at", Mongo::DESCENDING]]
  index [["location.coordinates", Mongo::GEO2D]], :min => -180, :max => 180
  index(
    [
      [ "social_connects.uid", Mongo::ASCENDING ],
      [ "social_connects.provider", Mongo::ASCENDING ]
    ]
  )

  embeds_many :social_connects
  embeds_one :current_post, :class_name => 'PostSnippet'
  embeds_one :location, as: :has_location, :class_name => 'LocationSnippet'
  has_many :tags
  has_many :normal_posts
  has_many :invite_posts
  has_many :comments
  has_many :lists
  has_many :notifications
  has_many :pings

  validates :email, :first_name, :last_name, :gender, :presence => true
  validates :gender, :inclusion => { :in => ["m", "f"], :message => "Please enter a valid gender." }
  validates :email, :uniqueness => { :case_sensitive => false }
  attr_accessible :first_name, :last_name, :gender, :birthday, :email, :password, :password_confirmation, :remember_me, :social_connected

  before_create :generate_username, :set_location_snippet
  after_create :add_to_soulmate, :save_profile_image, :send_welcome_email, :update_invites
  before_destroy :remove_from_soulmate

  scope :inactive, where(:last_sign_in_at.lte => Chronic.parse('1 month ago'))

  # Return the users slug instead of their ID
  def to_param
    "#{encoded_id}-#{self.fullname.parameterize}"
  end

  def generate_username
    self.username = "#{first_name}.#{last_name}"
  end

  def set_location_snippet
    location = City.where(name: "New York City").first
    self.location = LocationSnippet.new(
            city: location.name,
            state_code: location.state_code,
            coordinates: location.coordinates
    )
    self.location.id = location.id
  end

  # Pull image from social media, or gravatar
  def save_profile_image
    hash = Digest::MD5.hexdigest(email.downcase)+'.jpeg'

    image_url = if connected_with? 'facebook'
                  "http://graph.facebook.com/#{username}/picture?type=large"
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
      Notification.add(user, 'follow', true, false, false, self, [Chronic.parse('today at 12:01am'), Chronic.parse('today at 11:59pm')], nil)
      follow.active = true
      follow.save

      self.following_users << user.id
      self.following_users_count += 1
      user.followers_count += 1
      Resque.enqueue(SmUserFollowUser, id.to_s, user.id.to_s)
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
      Notification.remove(user, 'follow', self, nil, nil)
      follow.active = false
      follow.save

      self.following_users.delete(user.id)
      self.following_users_count -= 1
      user.followers_count -= 1
      Resque.enqueue(SmUserUnfollowUser, id.to_s, user.id.to_s)
    end
  end

  def pinged_today_by?(user_id)
    pings_today_date && pings_today_date >= Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))) && pings_today.include?(user_id)
  end

  def add_ping(user)
    unless pinged_today_by? user.id
      unless pings_today_date && pings_today_date >= Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5)))
        self.pings_today_date = Time.now
        self.pings_today = Array.new
      end
      Ping.create(:pinged_user_id => id, :user_id => user.id)
      self.pings_today << user.id
      self.pings_count += 1
    end
  end

  def connected_with? provider
    social_connects.each do |social|
      return social if social.provider == provider
    end
    nil
  end

  def revert_to_last_post_today
    latest_not_current_post = NormalPost.where(:user_id => id, :current => false, :status => 'Active', :created_at.gte => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5)))).first

    if latest_not_current_post
      latest_not_current_post.current = true
      latest_not_current_post.save
    end
  end

  def posted_today?
    current_post && current_post.created_at >= Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5)))
  end

  def gender_pronoun
    if gender == 'm' then 'he' else 'she' end
  end

  def gender_possesive
    if gender == 'm' then 'his' else 'her' end
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

  def facebook
    connection = social_connects.detect{|connection| connection.provider == 'facebook'}
    if connection
      @fb_user ||= Koala::Facebook::API.new(connection.token)
    else
      nil
    end
  end

  def add_to_soulmate
    Resque.enqueue(SmCreateUser, id.to_s)
  end

  def remove_from_soulmate
    Resque.enqueue(SmDestroyUser, id.to_s)
  end

  def encoded_id
    public_id.to_i.to_s(36)
  end

  class << self
    def find_by_encoded_id(id)
      where(:public_id => id.to_i(36)).first
    end

    def undecided(user)

      or_criteria = []
      or_criteria << {"current_post.created_at" => { "$lt" => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))) }}
      or_criteria << {:current_post => {"$exists" => false}}

      where(:_id.in => user.following_users).any_of(or_criteria)
    end

    # Omniauth providers
    def find_by_omniauth(omniauth, signed_in_resource=nil)
      data = omniauth['extra']['user_hash']
      user = User.where("social_connects.uid" => omniauth['uid'], 'social_connects.provider' => omniauth['provider']).first

      # Try to get via email if user not found and email provided
      unless user || !data['email']
        user = User.where(:email => data['email']).first
      end

      # If we found the user, update their token
      if user
        connect = user.social_connects.detect{|connection| connection.uid == omniauth['uid'] && connection.provider == omniauth['provider']}
        # Is this a new connection?
        unless connect
          connect = SocialConnect.new(:uid => omniauth["uid"], :provider => omniauth['provider'])
          user.social_connects << connect
        end
        # Update the token
        connect.token = omniauth['credentials']['token']
      else # Create a new user with a stub password.
        gender = data["gender"] == 'male' ? 'm' : 'f'
        user = User.new(
                first_name: data["first_name"], last_name: data["last_name"],
                gender: gender, email: data["email"], password: Devise.friendly_token[0,20]
        )
        user.birthday = Chronic.parse(data["birthday"]) if data["birthday"]
        user.social_connects << SocialConnect.new(:uid => omniauth["uid"], :provider => omniauth['provider'], :token => omniauth['credentials']['token'])
      end

      user.save
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
  end
end

