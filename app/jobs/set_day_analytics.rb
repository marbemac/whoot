class SetDayAnalytics
  @queue = :slow

  def self.perform()
    DayAnalytic.set_today_averages
  end
end