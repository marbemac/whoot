class Post
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :status, :default => 'Active'
  field :current, :default => true
  field :night_type
  field :user_id

  embeds_one :venue, :as => :has_venue, :class_name => 'VenueSnippet'
  embeds_one :location, as: :has_location, :class_name => 'LocationSnippet'
  has_many :comments
  belongs_to :user

  validates :night_type, :inclusion => { :in => ["working", "low_in", "low_out", "big_out"], :message => "Please select a post type below! (working, staying in, relaxing, or partying)" }
  attr_accessor :venue_id
  attr_accessible :night_type, :tags_string, :venue, :venue_id
  before_create :set_location_snippet
  before_create :set_venue_snippet

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
      errors.add(:tags, "You can only use 5 words! You inputted #{tags.length} words.")
    end
  end

  def max_characters
    count = 0
    if tags.length > 0
      tags.each {|tag| count += tag.name.length}
    end

    if count > 40
      errors.add(:tags, "You can only use 40 characters! You inputted #{count} characters.")
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
    if @venue_id
      venue = Venue.find(@venue_id)
      if venue
        self.venue = VenueSnippet.new(
                name: venue.name,
                address: venue.address,
                coordinates: venue.coordinates
        )
        self.venue.id = venue.id
      end
    end
  end

end
