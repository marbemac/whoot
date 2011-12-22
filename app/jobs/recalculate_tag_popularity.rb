class RecalculateTagPopularity
  include Resque::Plugins::UniqueJob

  @queue = :popularity

  def initialize()
    map    = "function() { " +
      "if (this.tag) { " +
      " emit(this.tag._id, 1); " +
      "}; " +
    "};"
    reduce = "function(key, value) { " +
      "var sum = 0; " +
      "value.forEach(function(doc) { " +
      " sum += doc; " +
      "}); " +
      "return sum; " +
    "};"

    @results = Post.collection.map_reduce(map, reduce, :query => {:created_at => {'$gte' => Post.cutoff_time}, :current => true}, :out => "pop-tags")

    tags = Tag.all
    tags.each do |tag|
      @results.find("_id" => tag.id).each do |doc|
        tag.popularity = doc["value"].to_i
        tag.save!
      end
    end

    map = "function() { " +
      "if (this.tag) { " +
      " emit(this.tag._id, {id: this.tag._id, amount: 1, name: this.tag.name}); " +
      "}; " +
    "};"
    reduce = "function(key, values) { " +
      "var sum = 0; " +
      "values.forEach(function(doc) { " +
      " sum += doc.amount; " +
      "}); " +
      "return {id: values[0].id, amount: sum, name: values[0].name}; " +
    "};"

    cities = City.all
    cities.each do |city|
      @results = Post.collection.map_reduce(map, reduce, :query => {:created_at => {'$gte' => Post.cutoff_time}, :current => true, "location._id" => city.id}, :out => "pop-#{city.name.to_url}-#{city.state_code}-tags")
      TrendingTag.where(city_id: city.id).delete_all
      @results.find().each do |doc|
        tag = TrendingTag.new(
                :name => doc["value"]["name"],
                :popularity => doc["value"]["amount"].to_i
        )
        tag.city_id = city.id
        tag.id = doc["value"]["id"]
        tag.save!
      end
    end
  end

  def self.perform()
    new()
  end
end