class ApiLocationsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def index
    cities = City.all()

    render :json => cities.map {|c| c.as_json}
  end
end