class School
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :name
  field :coordinates, :type => Array
  index [[:coordinates, Mongo::GEO2D]], :min => -180, :max => 180

  embedded_in :city

end