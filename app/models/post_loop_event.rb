class PostLoopEvent < PostEvent
  embeds_one :user_snippet, :as => :user_assignable, :class_name => 'UserSnippet'

  def user
    user_snippet
  end

  def icon
    "loop-1616"
  end

  def text
    " looped in"
  end

  def api_text
    "Looped In"
  end

  def as_json
    {
            :type => _type,
            :content => api_text,
            :user => user_snippet.as_json
    }
  end
end