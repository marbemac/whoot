class Ping
  include Mongoid::Document
  include Mongoid::Timestamps

  field :pinged_user_id
  field :user_id

  belongs_to :user

  class << self
    @limit = 3
  end
end