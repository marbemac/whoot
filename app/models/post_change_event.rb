class PostChangeEvent < PostEvent
  field :night_type
  field :tag
  field :venue_name
  field :venue_id
  field :venue_public_id

  def user
    _parent.user_snippet
  end

  def icon
    "user-small"
  end

  def text
    text = " is <span class='#{night_type}'>#{_parent.night_type_short(night_type.to_sym)}</span>"
    if tag
      text += "... #{tag}"
    end
    if venue_name
      text += " (#{venue_name})"
    end
    text
  end

  def api_text
    text = "Is #{_parent.night_type_short(night_type.to_sym)}"
    if tag
      text += "... #{tag}"
    end
    if venue_name
      text += " (#{venue_name})"
    end
    text
  end

  def as_json
    {
            :type => _type,
            :night_type => night_type,
            :tag => tag,
            :venue_name => venue_name,
            :venue_id => venue_id,
            :content => api_text
    }
  end
end