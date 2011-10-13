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
  field :dedicated, :default => false
  field :coordinates, :type => Array

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

  after_save :update_denorms
  after_validation :geocode
  after_create :add_to_soulmate
  before_destroy :remove_from_soulmate

  def to_param
    "#{self.public_id.to_i.to_s(36)}-#{self.name.parameterize}"
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

  def add_to_soulmate
    Resque.enqueue(SmCreateVenue, id.to_s)
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