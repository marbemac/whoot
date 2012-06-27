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

  index :name
  index [[:coordinates, Mongo::GEO2D]], :min => -180, :max => 180

  geocoded_by :fullname
  embeds_many :schools

  after_validation :geocode
  before_destroy :change_to_elsewhere

  def fullname
    "#{name}, #{state_code}"
  end

  def coordinates_string
    if coordinates then coordinates.join(',') else '' end
  end

  def coordinates_string=(coordinates_string)
    self.coordinates = coordinates_string.split(',')
  end

  def change_to_elsewhere
    elsewhere = City.where(:name => "Elsewhere").first
    if elsewhere
      Post.where("location._id" => id).asc(:created_at).each do |post|
        post.set_user_location(elsewhere)
        post.save
      end
      User.where("location._id" => id).asc(:created_at).each do |user|
        user.location = LocationSnippet.new(
            city: elsewhere.name,
            state_code: elsewhere.state_code,
            coordinates: elsewhere.coordinates
        )
        user.save
      end
    end
  end
end