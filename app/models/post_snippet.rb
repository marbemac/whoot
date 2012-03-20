class PostSnippet
  include Mongoid::Document

  field :night_type
  field :created_at, :type => Time
  field :comment_id

  embedded_in :post_assignable, polymorphic: true

  embeds_one :venue, :as => :has_venue, :class_name => 'VenueSnippet'
  embeds_one :tag, :as => :taggable, :class_name => 'TagSnippet'

  class << self
    def conver_for_api(snippet)
      if snippet && snippet.created_at > Post.cutoff_time
        {
          :id => snippet.id,
          :night_type => snippet.night_type,
          :created_at => snippet.created_at,
          :tag => tag,
          :venue => Venue.convert_for_api(snippet.venue)
        }
      else
        nil
      end
    end
  end

end