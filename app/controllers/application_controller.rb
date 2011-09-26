class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :init, :set_feed_filters, :set_user_time_zone
  layout :layout

  def has_permission?(object, target, permission)
    object.has_role?("admin") || target.has_permission?(object.id, permission)
  end

  def is_users_page?
    if current_user.slug != params[:id] && !current_user.has_role?("admin")
      flash[:notice] = "You don't have permission to access this page!"
      redirect_to root_path
    end
  end

  private

  # Used to display the page load time on each page
  def init
    @start_time = Time.now
  end

  def set_feed_filters
    if !session[:feed_filters]
      session[:feed_filters] =
              {
                :display => ['working', 'low_in', 'low_out', 'big_out'],
                :sort => {:target => 'created_at', :order => 'DESC'},
                :layout => 'list'
              }
    end
  end

  def set_user_time_zone
    Time.zone = current_user.time_zone if signed_in?
  end

  def layout
    # use ajax layout for ajax requests
    request.xhr? ? "ajax" : "application"
  end

end
