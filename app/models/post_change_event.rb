class PostChangeEvent < PostEvent
  field :night_type
  embeds_one :venue, :as => :has_venue, :class_name => 'VenueSnippet'
end