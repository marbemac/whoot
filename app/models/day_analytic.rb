class DayAnalytic
  include Mongoid::Document

  field :night_type
  field :wday
  field :total, :default => 0
  field :divisor, :default => 0
  field :average, :default => 0

  def self.get_change(night_type, percentage_now)
    analytic = self.where(:wday => Chronic.parse("5 hours ago").wday, :night_type => night_type).first
    if analytic
      percentage_now - analytic.average
    else
      0
    end
  end

  def self.set_today_averages
    nyc = City.where(:name => "New York City").first
    analytics = Post.analytics(Post.city_feed(nyc.id), false)
    analytics.each do |night_type, data|
      avg = self.where(:wday => Chronic.parse("5 hours ago").wday, :night_type => night_type).first
      avg = self.create(:wday => Chronic.parse("5 hours ago").wday, :night_type => night_type) unless avg
      avg.total += data[:now]
      avg.divisor += 1
      avg.average = avg.total.to_f / avg.divisor.to_f
      avg.save
    end
  end
end