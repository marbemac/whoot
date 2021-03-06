class PingsController < ApplicationController
  before_filter :authenticate_user!

  def create
    target_user = User.find(params[:id])
    if target_user
      if current_user.pings_sent_today < Ping.max_per_day
        target_user.add_ping(current_user)
        if target_user.save && current_user.save && target_user.settings.email_ping && !target_user.device_token
          PingMailer.new_ping(target_user).deliver
        elsif target_user.device_token
          msg = "Someone pinged you on The Whoot! Login and post to let them know what you're up to tonight."
          Notification.send_push_notification(target_user.device_token, target_user.device_type, msg, target_user.unread_notification_count, nil)
        end
        if params[:format] == :api
          response = {:json => {:status => 'ok'}}
        else
          response = {:json => {:status => 'ok', :target => '.ping_'+target_user.id.to_s, :toggle_classes => ['btn pingB', 'pinged'], :event => "used_ping"}, :status => 201}
        end
      else
        response = {:json => {:status => 'error', :message => "You have used all #{Ping.max_per_day} pings today!"}, :status => 404}
      end
    else
      response = {:json => {:status => 'error', :message => 'Target user not found!'}, :status => 404}
    end

    render response
  end
end