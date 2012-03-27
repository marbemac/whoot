# require 'json'
# 
# class SmDestroyTag
#   include Resque::Plugins::UniqueJob
# 
#   @queue = :soulmate_tag
# 
#   def self.perform(tag_id)
#     Soulmate::Loader.new("tag").remove({'id' => tag_id})
#   end
# end