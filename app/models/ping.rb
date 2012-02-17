class Ping
  include Mongoid::Document
  include Mongoid::Timestamps

  field :pinged_user_id
  field :user_id

  belongs_to :user

  class << self
    def max_per_day
      3
    end
  end
end