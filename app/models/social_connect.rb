class SocialConnect
  include Mongoid::Document

  field :provider
  field :uid, :type => String
  field :token, :type => String

  embedded_in :user

end