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
  field :coordinates, :type => Array
  index [[:coordinates, Mongo::GEO2D]], :min => -180, :max => 180

  auto_increment :_public_id

  geocoded_by :address

  validates :name, :uniqueness => { :case_sensitive => false }

  belongs_to :city

  after_save :update_denorms
  after_validation :geocode

  def to_param
    "#{self._public_id.to_i.to_s(36)}-#{self.fullname.parameterize}"
  end

  def update_denorms
    #if is_trendable_changed?
    #  NormalPost.where('tags._id' => id).update_all({"tags.$.is_trendable" => is_trendable})
    #end
  end

  class << self
    def find_by_encoded_id(id)
      where(:_public_id => id.to_i(36)).first
    end
  end

end