class PagesController < ApplicationController
  def home
    @title = "Home"

    if !signed_in?
      template = 'pages/splash'
    else
      template = 'pages/home'
    end

    render template
  end

  def about
    @title = "About"
  end

  def contact
    @title = "Contact"
  end

  def privacy
    @title = "Privacy"
  end

  def terms
    @title = "Terms"
  end

  def faq
    @title = "Terms"
  end
end
