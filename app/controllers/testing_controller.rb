class TestingController < ApplicationController

  def test
    authorize! :manage, :all


  end

end