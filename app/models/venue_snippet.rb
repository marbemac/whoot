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

  def city
    city = ''
    city += address.city if address.city
    city += ', ' + address.state_code if address.state_code
    city
  end

  def pretty_name
    if name.blank?
      pretty_address
    else
      name
    end
  end

  def pretty_address
    if address
      if address.street
        address.street
      elsif address.city
        address.city
      elsif address.state_code
        address.state_code
      end
    end
  end

  def full_address
    parts = []
    if address
      parts << address.street unless address.street.blank?
      parts << address.city unless address.city.blank?
      parts << address.state_code unless address.state_code.blank?
    end
    parts.join(', ')
  end

  def coordinates_string
    coordinates.ni? ? '' : coordinates.join(' ')
  end

  def coordinates_string=(string)
    self.coordinates = string.split(' ')
  end

  def as_json
    {
            :id => id.to_s,
            :address => address,
            :full_address => full_address,
            :coordinates => coordinates,
            :name => name,
            :pretty_name => pretty_name
    }
  end

end