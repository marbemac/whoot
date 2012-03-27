class TagSnippet
  include Mongoid::Document

  field :name

  embedded_in :taggable, :polymorphic => true

end