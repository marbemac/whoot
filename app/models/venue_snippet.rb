class VenueSnippet
  include Mongoid::Document

  # ALL Denormalized:
  # NormalPost.venue.*
  # InvitePost.venue.*
  field :name
  field :address
  field :coordinates, :type => Array
  index [[:coordinates, Mongo::GEO2D]], :min => -180, :max => 180

  embedded_in :has_venue, polymorphic: true

end