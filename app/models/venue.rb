class Venue
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Geocoder::Model::Mongoid

  field :status, :default => 'Active'
  field :name
  slug  :name
  field :type
  field :address
  field :price
  field :hours
  field :phone
  field :city_id
  field :user_id
  field :private, :default => false, :type => Boolean
  field :dedicated, :default => false
  field :coordinates, :type => Array
  field :aliases, :default => []

  auto_increment :public_id

  geocoded_by :address

  index [[:coordinates, Mongo::GEO2D]], :min => -180, :max => 180
  index :public_id
  index :slug, :unique => true
  index(
    [
      [ :city_id, Mongo::ASCENDING ],
      [ :slug, Mongo::ASCENDING ],
      [ :dedicated, Mongo::DESCENDING ]
    ]
  )

  validates :name, :uniqueness => { :case_sensitive => false }

  belongs_to :city
  belongs_to :user

  before_create :set_self_alias
  after_save :update_denorms
  after_validation :geocode
  after_create :check_duplicate
  before_destroy :remove_from_soulmate

  attr_accessible :name, :type, :address, :price, :hours, :phone, :city_id, :private, :dedicated, :coordinates, :coordinates_string

  def to_param
    "#{self.public_id.to_i.to_s(36)}-#{self.name.parameterize}"
  end

  def set_self_alias
    self.aliases ||= []
    add_alias(name, false)
  end

  def add_alias(content, add_soulmate=true)
    url = content.to_url
    self.aliases << url unless self.aliases.include?(url)
    Resque.enqueue(SmCreateVenue, id.to_s) if add_soulmate
  end

  def update_denorms
    updates = Hash.new
    if name_changed?
      updates["venue.name"] = self.name
    end
    if address_changed?
      updates["venue.address"] = self.address
      updates["venue.coordinates"] = self.coordinates
    end

    unless updates.empty?
      Post.where("venue._id" => id).update_all(updates)
    end
  end

  def coordinates_string
    if coordinates then coordinates.join(',') else '--' end
  end

  def check_duplicate
    if private == false && coordinates
      found = Venue.where(:coordinates => coordinates[0], :coordinates => coordinates[1], :_id.ne => id).first
      if found
        Post.where("venue._id" => id).update_all(
                "venue._id" => found.id,
                "venue.address" => found.address,
                "venue.public_id" => found.public_id,
                "venue.private" => found.private,
                "venue.coordinates" => found.coordinates
        )
        found.add_alias(name)
        found.save
        self.delete
      else
        Resque.enqueue(SmCreateVenue, id.to_s)
      end
    else
      Resque.enqueue(SmCreateVenue, id.to_s)
    end
  end

  def remove_from_soulmate
    Resque.enqueue(SmDestroyVenue, id.to_s, city_id)
  end

  class << self
    def find_by_encoded_id(id)
      where(:public_id => id.to_i(36)).first
    end
  end

end