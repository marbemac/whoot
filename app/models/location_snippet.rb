class LocationSnippet
  include Mongoid::Document

  field :city
  field :state_code
  field :school
  field :school_id
  field :coordinates, :type => Array

  embedded_in :has_location, polymorphic: true

  def full
    "#{city}, #{state_code}"
  end

end