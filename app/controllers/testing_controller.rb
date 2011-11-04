class TestingController < ApplicationController

  def test
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

      venues = Venue.where(:city_id => city.id)
      venues.each do |venue|
        pop_amount = 0
        @results.find("_id" => venue.id).each do |doc|
          venue.popularity = doc["value"].to_i
          venue.save!
        end

      end
    end
  end

end