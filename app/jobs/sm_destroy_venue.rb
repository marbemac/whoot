# require 'json'
# 
# class SmDestroyVenue
#   include Resque::Plugins::UniqueJob
# 
#   @queue = :soulmate_venue
# 
#   def self.perform(venue_id, bucket)
#     Soulmate::Loader.new(bucket).remove({'id' => venue_id})
#   end
# end