class Post
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :status, :default => 'Active'
  field :current, :default => true
  field :night_type
  field :comment_count, :default => 0
  field :user_id

  index(
    [
      [ :created_at, Mongo::DESCENDING ],
      [ :user_id, Mongo::ASCENDING ],
      [ :current, Mongo::DESCENDING ],
      [ :night_type, Mongo::ASCENDING ]
    ]
  )
  index :comment_count
  index "venue._id"
  index "venue.public_id"
  index [["venue.coordinates", Mongo::GEO2D]], :min => -180, :max => 180
  index [["location.coordinates", Mongo::GEO2D]], :min => -180, :max => 180

  embeds_one :venue, :as => :has_venue, :class_name => 'VenueSnippet'
  embeds_one :location, as: :has_location, :class_name => 'LocationSnippet'
  has_many :comments
  belongs_to :user

  validates :night_type, :inclusion => { :in => ["working", "low_in", "low_out", "big_out"], :message => "Please select a post type below! (working, staying in, relaxing, or partying)" }
  validate :valid_venue
  attr_accessible :night_type, :venue
  before_create :set_location_snippet, :set_venue_snippet

  def max_tags
    if tag && tag.name.split(' ').length > 3
      errors.add(:tags, "You can only use 3 words! Your tag is #{tag.name.split(' ').length} words long.")
    end
  end

  def max_characters
    if tag && tag.name.length > 40
      errors.add(:tags, "You can only use 40 characters for your tag! You tag has #{tag.name.length} characters.")
    end
  end

  def valid_venue
    if venue && !venue.address_string.blank? && venue.coordinates_string.blank?
      errors.add(:venue_address, "Your venue address is invalid. Please pick a valid address from the dropdown that appears when you start typing.")
    end
  end

  def night_type_short
    names = {:working => "Working", :low_in => "Staying In", :low_out => "Relaxing Out", :big_out => "Partying"}
    names[night_type.to_sym]
  end

  def night_type_noun
    names = {:working => "Work", :low_in => "Stay In", :low_out => "Relax Out", :big_out => "Party"}
    names[night_type.to_sym]
  end

  def created_by
    self[:created_by]
  end

  def set_location_snippet
    self.location = LocationSnippet.new(
            user.location.attributes
    )
  end

  def set_venue_snippet
    target_venue = nil
    if !venue.address_string.blank?
      target_venue = Venue.where(:address_string => venue.address_string).first
      unless target_venue
        target_venue = Venue.new(venue.attributes)
        target_venue.address_string = venue.address_string
        target_venue.user_id = user.id
        target_venue.save!
      end
    end

    if target_venue
      self.venue = VenueSnippet.new(
              name: target_venue.name,
              address: target_venue.address,
              public_id: target_venue.public_id,
              coordinates: target_venue.coordinates
      )
      self.venue.id = target_venue.id
    elsif !venue || !venue.address
      self.venue = nil
    end
  end

end
