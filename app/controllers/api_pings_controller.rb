class ApiPingsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def create
    target_user = User.find(params[:id])
    if target_user
      if current_user.pings_sent_today < Ping.max_per_day
        unless target_user.pinged_today_by? current_user.id
          target_user.add_ping(current_user)
          if target_user.save && current_user.save && target_user.settings.email_ping && !target_user.device_token
            PingMailer.new_ping(target_user.id.to_s).deliver
          elsif target_user.device_token
            Notification.send_push_notification(target_user.device_token, target_user.device_type, "Someone pinged you on The Whoot! Login and post to let them know what you're up to tonight.")
          end

          if params[:format] == :api
            response = build_ajax_response(:ok)
            status = 200
          else
            response = build_ajax_response(:ok)
            status = 200
          end
        else
          response = build_ajax_response(:error, nil, "You have already pinged this user today!")
          status = 404
        end
      else
        response = build_ajax_response(:error, nil, "You have used all #{Ping.max_per_day} pings today!")
        status = 404
      end
    else
      response = build_ajax_response(:error, nil, 'Target user not found!', nil)
      status = 404
    end

    render :json => response, :status => status
  end

end