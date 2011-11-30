class List
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :name
  field :status, :default => 'Active'
  field :list_users, :default => []
  field :list_users_count, :default => 0
  field :user_id

  index(
    [
      [ :user_id, Mongo::ASCENDING ],
      [ :status, Mongo::ASCENDING ]
    ]
  )

  belongs_to :user

  validates :name, :length => { :in => 2..30 }
  attr_accessible :name

  after_create :clear_caches
  after_destroy :clear_caches

  def in_list?(user_id)
    list_users.include? user_id
  end

  def add_user(user)
    if !in_list?(user.id)
      self.list_users << user.id
      self.list_users_count += 1
    end
  end

  def remove_user(user)
    if in_list?(user.id)
      self.list_users.delete user.id
      self.list_users_count -= 1
    end
  end

  def clear_caches

  end

end