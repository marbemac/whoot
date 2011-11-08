require 'json'

#TODO: We need to update the soulmate data when relevant venue data changes
class SmCreateVenue
  include Resque::Plugins::UniqueJob
  include Rails.application.routes.url_helpers
  include SoulmateHelper

  @queue = :soulmate_venue

  def initialize(venue)
    Soulmate::Loader.new("venue#{venue.city_id.to_s}").add(venue_nugget(venue))
  end

  def self.perform(venue_id)
    venue = Venue.find(venue_id)
    new(venue) if venue
  end
end