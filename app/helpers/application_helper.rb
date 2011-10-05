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

end
