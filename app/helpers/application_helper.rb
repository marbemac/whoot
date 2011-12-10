module ApplicationHelper

  # Return a title on a per-page basis.
  def title
    base_title = "The Whoot"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  # Return the page load time (defined in application_controller.rb init)
  def load_time
    "#{(Time.now-@start_time).round(4)}s"
  end

  # Parse text via markdown
  def markdown(text)
    options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :strikethrough]
    Redcarpet.new(text, *options).to_html.html_safe
  end

  # Devise helper
  # https://github.com/plataformatec/devise/wiki/How-To:-Display-a-custom-sign_in-form-anywhere-in-your-app
  def resource_name
    :user
  end

  # Devise helper
  def resource
    @resource ||= User.new
  end

  # Devise helper
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def static_data
    data = {
            :myId => signed_in? ? current_user.id.to_s : 0,
            :userAutoUrl => '/soul-data/search',
            :userAutoBucket => signed_in? ? current_user.id.to_s : '',
            :userVenueAutoBucket => signed_in? ? "venue#{current_user.id.to_s}" : '',
            :venueAutoBucket => signed_in? ? "venue#{current_user.location.id.to_s}" : '',
            :venueAutoUrl => '/soul-data/search',
            :tagAutoUrl => '/soul-data/search',
            :commentAjaxPath => comments_ajax_path,
            :votesAjaxPath => votes_ajax_path,
            :postAjaxPath => posts_ajax_path
    }
    Yajl::Encoder.encode(data)
  end

  def calculate_time_of_day
    hour = Time.zone.now.hour
    case hour
      when 5...18 then :day
      when 18...20 then :sunset
      else :night
    end
  end

  def pretty_time(time)
    a = (Chronic.parse('today at 11:59pm')-time).to_i

    case a
      when 0..86400 then 'Today'
      when 86401..172800 then 'Yesterday'
      when 172801..518400 then time.strftime("%A") # just output the day for anything in the last week
      else time.strftime("%B %d")
    end
  end

end
