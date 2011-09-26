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

  field :gender
  field :birthday, :type => Date
  field :time_zone, :type => String, :default => "Eastern Time (US & Canada)"

  field :roles, :default => []
  field :following_users_count, :type => Integer, :default => 0
  field :following_users, :default => []
  field :followers_count, :type => Integer, :default => 0
  field :unread_notification_count, :type => Integer, :default => 0
  field :pings_count, :type => Integer, :default => 0

  auto_increment :_public_id

  embeds_many :social_connects
  embeds_one :current_post, :class_name => 'PostSnippet'
  has_many :tags
  has_many :normal_posts
  has_many :invite_posts
  has_many :comments

  validates :email, :first_name, :last_name, :gender, :presence => true
  validates :gender, :inclusion => { :in => ["m", "f"], :message => "Please enter a valid gender." }
  validates :email, :uniqueness => { :case_sensitive => false }
  attr_accessible :first_name, :last_name, :gender, :birthday, :email, :password, :password_confirmation, :remember_me, :social_connected

  before_create :generate_username
  after_create :save_profile_image

  # Return the users slug instead of their ID
  def to_param
    "#{self._public_id.to_i.to_s(36)}-#{self.fullname.parameterize}"
  end

  def generate_username
    self.username = "#{first_name}.#{last_name}"
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

  def fullname
    "#{self.first_name} #{self.last_name}"
  end

  # Checks to see if this user has a given role
  def has_role?(role)
    self.roles.include? role
  end

  # Adds a role to this user
  def grant_role(role)
    self.roles << role unless self.roles.include?(role)
  end

  # Removes a role from this user
  def revoke_role(role)
    if self.roles
      self.roles.delete(role)
    end
  end

  def is_following_user?(user_id)
    self.following_users.include? user_id
  end

  def toggle_follow_user(user)
    if is_following_user? user.id
      unfollow_user user
    else
      follow_user user
    end
  end

  def follow_user(user)
    if !self.following_users.include?(user.id)
      self.following_users << user.id
      self.following_users_count += 1
      user.followers_count += 1
    end
  end

  def unfollow_user(user)
    if self.following_users.include?(user.id)
      self.following_users.delete(user.id)
      self.following_users_count -= 1
      user.followers_count -= 1
    end
  end

  def connected_with? provider
    social_connects.each do |social|
      return social if social.name == provider
    end
    nil
  end

  class << self
    def find_by_encoded_id(id)
      where(:_public_id => id.to_i(36)).first
    end

    def undecided(user)

      or_criteria = []
      or_criteria << {"current_post.created_at" => { "$lt" => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5))) }}
      or_criteria << {:current_post => {"$exists" => false}}

      where(:_id.in => user.following_users).any_of(or_criteria)
    end

    # Omniauth providers
    def find_for_facebook(access_token, signed_in_resource=nil)
      data = access_token['extra']['user_hash']
      if user = User.where(email: data["email"]).first
        user
      else # Create a user with a stub password.
        gender = data["gender"] == 'male' ? 'm' : 'f'
        user = User.new(
                first_name: data["first_name"], last_name: data["last_name"],
                gender: gender, email: data["email"], password: Devise.friendly_token[0,20],
                birthday: data["birthday"]
        )
        user.social_connects << SocialConnect.new(:id => data["id"], :name => "facebook")
        user.save
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
        object[:created_by] = users.find(object.user_id)
        object
      end

      joined
    end
  end
end

