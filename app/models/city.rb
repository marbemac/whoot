class City
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Geocoder::Model::Mongoid

  field :name
  field :state_code
  slug :name
  field :coordinates, :type => Array
  index [[:coordinates, Mongo::GEO2D]], :min => -180, :max => 180

  geocoded_by :fullname
  embeds_many :schools

  after_validation :geocode

  def fullname
    "#{name}, #{state_code}"
  end

  def coordinates_string
    if coordinates then coordinates.join(',') else '' end
  end

  def coordinates_string=(coordinates_string)
    self.coordinates = coordinates_string.split(',')
  end

end