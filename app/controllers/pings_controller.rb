class PingsController < ApplicationController
  before_filter :authenticate_user!

  def create
    target_user = User.find(params[:id])
    if target_user
      target_user.add_ping(current_user)
      if target_user.save && target_user.settings.email_ping
        PingMailer.new_ping(target_user).deliver
      end
      if params[:format] == :api
        response = {:json => {:status => 'ok'}}
      else
        response = {:json => {:status => 'ok', :target => '.ping_'+target_user.id.to_s, :toggle_classes => ['btn pingB', 'pinged']}, :status => 201}
      end
    else
      response = {:json => {:status => 'error', :message => 'Target user not found!'}, :status => 404}
    end

    render response
  end
end