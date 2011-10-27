class VenueSnippet
  include Mongoid::Document

  field :name
  field :address
  field :public_id
  field :private
  field :coordinates, :type => Array

  embedded_in :has_venue, polymorphic: true

  def to_param
    "#{self.public_id.to_i.to_s(36)}-#{self.name.parameterize}"
  end

  def coordinates_string
    coordinates.join(',')
  end

  def coordinates_string=(string)
    self.coordinates = string.split(',')
  end

end