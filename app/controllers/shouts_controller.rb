class ShoutsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def create
    render :json => {:foo => :bar}, :status => :created
  end

end