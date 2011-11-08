class VenueSnippet
  include Mongoid::Document

  field :name
  field :public_id
  field :coordinates, :type => Array

  embeds_one :address, :as => :has_address, :class_name => 'Address'
  embedded_in :has_venue, polymorphic: true

  attr_accessor :address_string

  def to_param
    "#{self.public_id.to_i.to_s(36)}-#{self.name.parameterize}"
  end

  def pretty_name
    pretty = ''
    if !name.blank?
      pretty = name+', '+address.state_code
    else
      if address.street
        pretty += address.street
      elsif address.city
        pretty += address.city
      end
      pretty += ', '+address.state_code
    end
    pretty
  end

  def full_address
    full = ''
    if address.street
      full += address.street
    end
    if address.city
      full += ', '+address.city
    end
    full += ', '+address.state_code
    full
  end

  def coordinates_string
    coordinates.join(' ')
  end

  def coordinates_string=(string)
    self.coordinates = string.split(' ')
  end

end