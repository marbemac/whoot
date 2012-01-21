class TestingController < ApplicationController

  def test
    SendUserNotification.perform(BSON::ObjectId("4eef8ad2aaf90620b0000002"))

    #foo = Notification.send_push_notification('F2A2707EBD9E006F60F3C3B3BDA0911BCC1EAB2F087473F59C744E8D3E427DDF', 'IOS', "Whattup James")
    #x = 'y'
    #render :none
  end

end