class TestingController < ApplicationController

  def test
    sms = Moonshado::Sms.new("12404182338", "test")
    sms.deliver_sms
  end

end