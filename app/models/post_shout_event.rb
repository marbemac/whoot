class PostShoutEvent < PostEvent
  field :content

  validates_length_of :content, :minimum => 5, :maximum => 40, :message => "Shout must be between 5 and 40 characters"

  def user
    _parent.user_snippet
  end

  def text
    content
  end

  def api_text
    content
  end

  def as_json
    {
            :type => _type,
            :content => api_text,
            :user => user_snippet.as_json,
            :created_at => created_at,
            :created_at_pretty => pretty_time(created_at),
            :created_at_day => pretty_day(created_at)
    }
  end
end