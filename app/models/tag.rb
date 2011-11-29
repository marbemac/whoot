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
  field :score, :default => 1
  field :user_id
  field :popularity, :default => 0

  index :slug, :unique => true
  index [[:popularity, Mongo::DESCENDING]]

  belongs_to :user

  validates :name, :uniqueness => { :case_sensitive => false }

  after_destroy :remove_from_soulmate
  after_save :update_denorms,:add_to_soulmate

  def update_denorms
  end

  def add_to_soulmate
    Resque.enqueue(SmCreateTag, id.to_s)
  end

  def remove_from_soulmate
    Resque.enqueue(SmDestroyTag, id.to_s)
  end

  class << self
    def convert_for_api(tag)
      if tag
        {
                :id => tag.id,
                :name => tag.name
        }
      else
        nil
      end
    end
  end

end