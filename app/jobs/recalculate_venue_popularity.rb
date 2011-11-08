class RecalculateVenuePopularity
  include Resque::Plugins::UniqueJob

  @queue = :popularity

  def initialize()
    map    = "function() { " +
      "if (this.venue) { " +
      " emit(this.venue._id, 1); " +
      "}; " +
    "};"
    reduce = "function(key, value) { " +
      "var sum = 0; " +
      "value.forEach(function(doc) { " +
      " sum += doc; " +
      "}); " +
      "return sum; " +
    "};"

    cities = City.all

    cities.each do |city|
      @results = NormalPost.collection.map_reduce(map, reduce, :query => {:created_at => {'$gte' => Chronic.parse('today at 5:00am', :now => (Time.now - (60*60*5)))}, :current => true, 'location._id' => city.id}, :out => "pop-#{city.name.to_url}-#{city.state_code}-venues")

      venues = Venue.near(city.to_coordinates, 20).to_a
      venues.each do |venue|
        @results.find("_id" => venue.id).each do |doc|
          venue.popularity = doc["value"].to_i
          venue.save!
        end
      end
    end
  end

  def self.perform()
    new()
  end
end