class SocialConnect
  include Mongoid::Document

  identity :type => Integer

  field :name

  embedded_in :user

end