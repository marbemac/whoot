class TestingController < ApplicationController

  def test
    authorize! :manage, :all

    @codes = BeerCode.all.asc(:code)
  end

end