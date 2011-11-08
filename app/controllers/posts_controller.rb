class PostsController < ApplicationController
  before_filter :authenticate_user!

  def update_feed_display
    if session[:feed_filters][:display].include? params[:value]
      session[:feed_filters][:display].delete(params[:value])
    else
      session[:feed_filters][:display] << params[:value]
    end

    render json: {:replace_target => '#page_content', :content => render_cell(:normal_post, :feed), :event => 'updated_feed_filters'}
  end

  def update_feed_sort
    session[:feed_filters][:sort][:target] = params[:value]

    render json: {:replace_target => '#page_content', :content => render_cell(:normal_post, :feed)}
  end

  def new
    if signed_in? && current_user.posted_today?
      redirect_to root_path
    end
  end

end