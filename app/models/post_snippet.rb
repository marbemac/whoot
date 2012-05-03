class PostSnippet
  include Mongoid::Document
  include Mongoid::Timestamps
  include ModelUtilitiesHelper

  field :night_type
  field :address_original
  field :comment_id
  field :suggestions

  embedded_in :post_assignable, polymorphic: true

  embeds_one :venue, :as => :has_venue, :class_name => 'VenueSnippet'
  embeds_one :tag, :as => :taggable, :class_name => 'TagSnippet'

  def as_json(options={})
    data = {
            :id => id.to_s,
            :tag => tag,
            :night_type => night_type,
            :address_original => address_original,
            :venue => venue,
            :created_at => created_at,
            :created_at_pretty => pretty_time(created_at),
            :created_at_day => pretty_day(created_at),
            :comment_id => comment_id,
            :suggestions => suggestions
    }

    data
  end

  class << self
    def conver_for_api(snippet)
      if snippet && snippet.created_at > Post.cutoff_time
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