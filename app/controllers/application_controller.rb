class ApplicationController < ActionController::Base
  #protect_from_forgery
  before_filter :init, :set_request_type, :set_feed_filters, :set_user_time_zone, :initialize_mixpanel, :require_post#, :prepare_for_mobile
  layout :layout

  def authenticate_admin_user!
    unless can? :manage, :all
      redirect_to root_path
    end
  end

  def permission?(object, target, permission)
    object.role?("admin") || target.has_permission?(object.id, permission)
  end

  def is_users_page?
    if current_user.slug != params[:id] && !current_user.role?("admin")
      flash[:notice] = "You don't have permission to access this page!"
      redirect_to root_path
    end
  end

  def set_content_type(type)
    response.headers['content-type'] = type
  end

  def build_ajax_response(status, redirect=nil, flash=nil, errors=nil, extra=nil)
    response = {:status => status, :event => "#{params[:controller]}_#{params[:action]}"}
    response[:redirect] = redirect if redirect
    response[:flash] = flash if flash
    response[:errors] = errors if errors
    response.merge!(extra) if extra
    response
  end

  private

  # Used to display the page load time on each page
  def init
    @start_time = Time.now
  end

  def initialize_mixpanel
    if Rails.env.production?
      token = '3697e1a281169ebe4f972f32c63c1878'
    elsif Rails.env.staging?
      token = 'a42d020f0cad9a401cc8a7879880b7b0'
    else
      token = '4ba8c8fe2bdc121f677297cb6381a9a8'
    end
    @mixpanel = Mixpanel::Tracker.new(token, request.env, true)
  end

  def set_feed_filters
    if !session[:feed_filters]
      session[:feed_filters] =
              {
                :display => ['working', 'low_in', 'low_out', 'big_out'],
                :sort => {:target => 'created_at', :order => 'DESC'}
              }
    end
  end

  def set_user_time_zone
    Time.zone = current_user.time_zone if signed_in?
    Chronic.time_class = Time.zone
  end

  def require_post
    if params[:format] != :api && request.get? && signed_in? && !current_user.posted_today? && params[:controller] != 'post' && params[:action] != 'new'
      redirect_to (new_post_path)
    end
  end

  def layout
    # use ajax layout for ajax requests
    request.xhr? ? "ajax" : "application"
  end

  def set_request_type
    # this fixes an IE 8 issue with refreshing page returning javascript response
    request.format = :html if request.format == "*/*"
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
  end

end
