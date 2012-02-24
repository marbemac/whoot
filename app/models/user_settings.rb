class UserSettings
  include Mongoid::Document

  field :email_comment, :default => true
  field :email_ping, :default => true
  field :email_follow, :default => true
  field :email_daily, :default => true # determines whether app users get daily push notifications

  embedded_in :user

end