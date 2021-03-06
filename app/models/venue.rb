class Venue
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :status, :default => 'Active'
  field :name
  field :type
  field :address_string
  field :price
  field :hours
  field :phone
  field :user_id
  field :coordinates, :type => Array
  field :popularity, :default => 0

  auto_increment :public_id

  geocoded_by :address_string do |obj,results|
    if geo = results.first
      number = geo.data['address_components'].detect{|component| component['types'].include?('street_number') }
      number = number['short_name'] if number
      route = geo.data['address_components'].detect{|component| component['types'].include?('route') }
      route = route['short_name'] if route
      if route
        if number
          address = "#{number} #{route}"
        else
          address = route
        end
      else
        address = nil
      end
      obj.address = Address.new(
              :street => address,
              :city => geo.city,
              :state_code => geo.state_code,
              :zipcode => geo.postal_code,
              :country => geo.country_code
      )
      obj.coordinates = [geo.longitude, geo.latitude]
    end
  end

  index (
          [
                  [:coordinates, Mongo::GEO2D, :min => -180, :max => 180],
                  [ :popularity, Mongo::DESCENDING ]
          ]
  )
  index (
          [
                  [:_id, Mongo::ASCENDING],
                  [ :popularity, Mongo::DESCENDING ]
          ]
        )
  index :public_id

  embeds_one :address, :as => :has_address, :class_name => 'Address'
  belongs_to :city
  belongs_to :user

  after_save :update_denorms
  after_validation :geocode, :if => lambda{ |obj| obj.address_string_changed? }
  after_create :check_duplicate
  before_destroy :remove_from_soulmate

  attr_accessible :name, :type, :address_string, :address, :price, :hours, :phone, :city_id, :dedicated, :coordinates, :coordinates_string

  def to_param
    "#{self.public_id.to_i.to_s(36)}-#{self.name.parameterize}"
  end

  def update_denorms
    updates = Hash.new
    if name_changed?
      updates["venue.name"] = self.name
    end
    if address_string_changed? && address
      updates["venue.address.street"] = self.address.street
      updates["venue.address.city"] = self.address.city
      updates["venue.address.state_code"] = self.address.state_code
      updates["venue.address.zipcode"] = self.address.zipcode
      updates["venue.address.country"] = self.address.country
      updates["venue.coordinates"] = self.coordinates
    end

    unless updates.empty?
      Post.where("venue._id" => id).update_all(updates)
    end
  end

  def coordinates_string
    if coordinates then coordinates.join(',') else '--' end
  end

  def check_duplicate
    if coordinates
      #found = Venue.where(:coordinates => coordinates[0], :coordinates => coordinates[1], :_id.ne => id).first
      #if found
      #  Post.where("venue._id" => id).update_all(
      #          "venue._id" => found.id,
      #          "venue.address" => found.address, # THIS HAS AN ERROR. Cannot update with an embedded doc.
      #          "venue.public_id" => found.public_id,
      #          "venue.coordinates" => found.coordinates
      #  )
      #  found.save
      #  self.delete
      #end
    end
  end

  def remove_from_soulmate
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

  class << self
    def find_by_encoded_id(id)
      where(:public_id => id.to_i(36)).first
    end

    def convert_for_api(venue)
      if venue
        data = {
              :id => venue.id,
              :name => venue.name,
              :address => venue.address,
              :coordinates => venue.coordinates,
        }
      else
        data = nil
      end
      data
    end
  end

end