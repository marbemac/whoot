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

  index :slug, :unique => true

  belongs_to :user

  validates :name, :uniqueness => { :case_sensitive => false }

  scope :uncategorized, where(is_trendable: false, is_stopword: false)
  scope :trendable, where(is_trendable: true)
  scope :stopword, where(is_stopword: true)

  after_save :update_denorms

  def update_denorms
    if is_trendable_changed?
      NormalPost.where('tags._id' => id).update_all({"tags.$.is_trendable" => is_trendable})
    end
  end

end