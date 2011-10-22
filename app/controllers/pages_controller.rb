class PagesController < ApplicationController
  def home
    @title = "Home"
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
end
