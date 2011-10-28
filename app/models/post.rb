class Post
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :status, :default => 'Active'
  field :current, :default => true
  field :night_type
  field :user_id

  index(
    [
      [ :created_at, Mongo::DESCENDING ],
      [ :user_id, Mongo::ASCENDING ],
      [ :current, Mongo::DESCENDING ],
      [ :night_type, Mongo::ASCENDING ]
    ]
  )
  index "venue._id"
  index [["venue.coordinates", Mongo::GEO2D]], :min => -180, :max => 180
  index [["location.coordinates", Mongo::GEO2D]], :min => -180, :max => 180

  embeds_one :venue, :as => :has_venue, :class_name => 'VenueSnippet'
  embeds_one :location, as: :has_location, :class_name => 'LocationSnippet'
  has_many :comments
  belongs_to :user

  validates :night_type, :inclusion => { :in => ["working", "low_in", "low_out", "big_out"], :message => "Please select a post type below! (working, staying in, relaxing, or partying)" }
  validate :valid_venue
  attr_accessor :venue_id
  attr_accessible :night_type, :tags_string, :venue, :venue_id
  before_create :set_location_snippet, :set_venue_snippet

  def tags_string
    tags_string = tags.map{|tag| tag.name}
    tags_string.join " "
  end

  def tags_string=(words)
    words = words.split(' ')
    words.each do |word|
      self.tags.new(:name => word.strip)
    end
  end

  def max_tags
    if tags.length > 5
      errors.add(:tags, "You can only use 5 words! You posted #{tags.length} words.")
    end
  end

  def max_characters
    count = 0
    if tags.length > 0
      tags.each {|tag| count += tag.name.length}
    end

    if count > 40
      errors.add(:tags, "You can only use 40 characters! You posted #{count} characters.")
    end
  end

  def valid_venue
    if @venue_id == '' && venue && venue.name != '' && venue.address == ''
      errors.add(:venue_address, "You must specify a venue address!")
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
    if !@venue_id.blank?
      target_venue = Venue.find(@venue_id)
    elsif !self.venue.name.blank?
      target_venue = Venue.where(:private => false).any_of({:slug => venue.name.to_url}, {:address => venue.address}).first
      if target_venue
        target_venue.add_alias(venue.name)
      else
        target_venue = Venue.new(venue.attributes)
        target_venue.user_id = user.id
      end
    end

    if target_venue
      target_venue.save
      self.venue = VenueSnippet.new(
              name: target_venue.name,
              address: target_venue.address,
              public_id: target_venue.public_id,
              coordinates: target_venue.coordinates,
              private: target_venue.private
      )
      self.venue.id = target_venue.id
    else
      self.venue = nil
    end
  end

end
