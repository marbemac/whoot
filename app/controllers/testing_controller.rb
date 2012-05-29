class TestingController < ApplicationController

  def test
    SendUserNotification.perform("4f832fc7ac8dde47f5000001")
  end

end