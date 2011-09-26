class Tag
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :status, :default => 'Active'

  # Denormalized:
  # Post.tags.name
  field :name

  slug  :name
  field :score, :default => 0

  # Denormalized:
  # Post.tags.is_trendable
  field :is_trendable, :default => false

  field :is_stopword, :default => false
  field :user_id

  belongs_to :user

  validates :name, :uniqueness => { :case_sensitive => false }

end