class VenueSnippet
  include Mongoid::Document

  field :name
  field :address
  field :_public_id
  field :coordinates, :type => Array
  index [[:coordinates, Mongo::GEO2D]], :min => -180, :max => 180

  embedded_in :has_venue, polymorphic: true

  def to_param
    "#{self._public_id.to_i.to_s(36)}-#{self.name.parameterize}"
  end

end