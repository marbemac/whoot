class UserSettings
  include Mongoid::Document

  field :email_comment, :default => true
  field :email_ping, :default => true
  field :email_follow, :default => true

  embedded_in :user

end