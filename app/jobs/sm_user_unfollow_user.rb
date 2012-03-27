# require 'json'
# 
# class SmUserUnfollowUser
#   include Resque::Plugins::UniqueJob
# 
#   @queue = :soulmate_user
# 
#   def self.perform(user_id, unfollow_user_id)
#     user = User.find(user_id)
#     Soulmate::Loader.new(user_id).remove({'id' => unfollow_user_id}) if user
#   end
# end