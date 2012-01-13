class TestingController < ApplicationController

  def test
    #foo = Urbanairship.register_device '1973ed07-3eea-41b7-b05a-25f7063e5a93'
    notification = {
      :schedule_for => [10.seconds.from_now],
      :apids => ['1973ed07-3eea-41b7-b05a-25f7063e5a93'],
      :android => {:alert => "Howdy. I'm a push notification from The Whoot!'"}
    }

    foo2 = Urbanairship.push notification
    x = 'y'
    render :none
  end

end