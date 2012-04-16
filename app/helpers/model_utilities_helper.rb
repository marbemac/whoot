module ModelUtilitiesHelper

  include ActionView::Helpers::DateHelper

  # 4 minutes ago, 5 hours ago, etc
  def pretty_time(date)
    pretty = time_ago_in_words(date, false).sub('about', '')+ ' ago'
    pretty == 'Today ago' ? 'just now' : pretty
  end

  # Today, yesterday, etc
  def pretty_day(time)
    a = (Chronic.parse('today at 11:59pm')-time).to_i

    case a
      when 0..86400 then 'Today'
      when 86401..172800 then 'Yesterday'
      when 172801..518400 then time.strftime("%A") # just output the day for anything in the last week
      else time.strftime("%B %d")
    end
  end

  # 1m, 4h, 2d, 3m, etc.
  def short_time(date)
    a = Time.now.to_i - date.to_i

    case a
      when 0..3600 then "#{(a/60).to_i}m"
      when 3601..86400 then "#{(a/3600).to_i}h"
      when 86401..2592000 then "#{(a/86400).to_i}d"
      else "#{(a/2592000).to_i}mo"
    end
  end

end