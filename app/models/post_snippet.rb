class PostSnippet
  include Mongoid::Document

  field :night_type
  field :created_at, :type => Time

  embedded_in :user

  embeds_one :venue, :as => :has_venue, :class_name => 'VenueSnippet'
  embeds_one :tag, :as => :taggable, :class_name => 'TagSnippet'

  class << self
    def conver_for_api(snippet)
      if snippet && snippet.created_at > Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5)))
        {
          :id => snippet.id,
          :night_type => snippet.night_type,
          :created_at => snippet.created_at,
          :tag => Tag.convert_for_api(snippet.tag),
          :venue => Venue.convert_for_api(snippet.venue)
        }
      else
        nil
      end
    end
  end

end