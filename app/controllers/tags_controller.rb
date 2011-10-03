class TagsController < ApplicationController
  before_filter :authenticate_admin_user!

  def make_trendable
    tag = Tag.find(params[:id])
    tag.is_stopword = false
    tag.is_trendable = true
    tag.save

    render json: {:status => 'OK', :event => 'made_tag_trendable', :flash => {:type => 'success', :message => 'Tag is now trendable'}}
  end

  def make_stopword
    tag = Tag.find(params[:id])
    tag.is_stopword = true
    tag.is_trendable = false
    tag.save

    render json: {:status => 'OK', :event => 'made_tag_stopword', :flash => {:type => 'success', :message => 'Tag is now a stopword'}}
  end

end
