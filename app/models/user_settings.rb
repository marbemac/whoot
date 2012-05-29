class UserSettings
  include Mongoid::Document

  field :email_comment, :default => true
  field :email_loop, :default => true
  field :email_ping, :default => true
  field :email_follow, :default => true
  field :email_daily, :default => true # determines whether app users get daily push notifications

  embedded_in :user

  def notification_types
    types = []
    types << "follow" if email_follow
    types << "loop" if email_loop
    types << "ping" if email_ping
    types = types + ["also", "comment"] if email_comment
    types
  end

  def as_json
    {
      :email_comment => email_comment,
      :email_loop => email_loop,
      :email_ping => email_ping,
      :email_follow => email_follow,
      :email_daily => email_daily
    }
  end
end