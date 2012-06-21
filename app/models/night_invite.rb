class NightInvite
  include Mongoid::Document

  field :phone_numbers, :default => []
  field :invited_user_ids, :default => []

  belongs_to :user

  attr_accessible :phone_numbers, :invited_user_ids
end