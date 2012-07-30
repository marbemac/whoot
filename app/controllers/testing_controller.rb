class TestingController < ApplicationController

  def test
    authorize! :manage, :all

    SetDayAnalytics.perform()

    @codes = []
    #@codes = BeerCode.all.asc(:code)
  end

end