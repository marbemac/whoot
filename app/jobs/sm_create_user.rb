require 'json'

#TODO: We need to update the soulmate data when relevant user data changes (username, main image, etc)
class SmCreateUser
  include Resque::Plugins::UniqueJob
  include Rails.application.routes.url_helpers
  include SoulmateHelper

  @queue = :soulmate_user

  def initialize(user)
    Soulmate::Loader.new("user").add(user_nugget(user))
  end

  def self.perform(user_id)
    user = User.find(user_id)
    new(user) if user
  end
end