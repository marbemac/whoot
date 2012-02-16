class SocialConnect
  include Mongoid::Document

  field :provider
  field :uid, :type => String
  field :token
  field :secret
  field :image

  embedded_in :user

end