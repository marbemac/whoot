require 'json'

class SmCreateTag
  include Resque::Plugins::UniqueJob
  include SoulmateHelper

  @queue = :soulmate_tag

  def initialize(tag)
    Soulmate::Loader.new("tag").add(tag_nugget(tag))
  end

  def self.perform(tag_id)
    tag = Tag.find(tag_id)
    new(tag) if tag
  end
end