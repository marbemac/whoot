require 'json'

#TODO: We need to update the soulmate data when relevant user data changes (username, main image, etc)
class SmUserFollowUser
  include Resque::Plugins::UniqueJob
  include Rails.application.routes.url_helpers
  include SoulmateHelper

  @queue = :soulmate_user

  def initialize(user, following)
    Soulmate::Loader.new(user.id.to_s).add(user_nugget(following))
  end

  def self.perform(user_id, following_user_id)
    user = User.find(user_id)
    following = User.find(following_user_id)
    new(user, following) if user && following
  end
end