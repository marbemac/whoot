class City
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :name
  field :state_code
  slug :name
  field :coordinates, :type => Array
  index [[:coordinates, Mongo::GEO2D]], :min => -180, :max => 180

  embeds_many :schools

  def coordinates_string
    if coordinates then coordinates.join(',') else '' end
  end

  def coordinates_string=(coordinates_string)
    self.coordinates = coordinates_string.split(',')
  end

end