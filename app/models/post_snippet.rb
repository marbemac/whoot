class PostSnippet
  include Mongoid::Document
  include Mongoid::Timestamps
  include ModelUtilitiesHelper

  field :night_type
  field :address_original
  field :comment_id
  field :suggestions
  field :comment_count, :default => 0
  field :loop_in_count, :default => 0
  field :tag

  embedded_in :post_assignable, polymorphic: true

  embeds_one :venue, :as => :has_venue, :class_name => 'VenueSnippet'

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
            :suggestions => suggestions,
            :comment_count => comment_count,
            :loop_in_count => loop_in_count
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
          :tag => snippet.tag ? {:id => nil, :name => snippet.tag} : nil,
          :venue => Venue.convert_for_api(snippet.venue)
        }
      else
        nil
      end
    end
  end

end