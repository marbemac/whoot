class TagSnippet
  include Mongoid::Document

  field :name
  field :is_trendable, :default => false

  embedded_in :taggable, polymorphic: true

end