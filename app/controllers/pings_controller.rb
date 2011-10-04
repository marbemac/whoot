class PingsController < ApplicationController
  before_filter :authenticate_user!

  def create
    target_user = User.find(params[:id])
    if target_user
      target_user.add_ping(current_user)
      #if target_user.save
      #  PingMailer.new_ping(target_user).deliver
      #end
      response = {:json => {:status => 'ok', :target => '.ping_'+target_user.id.to_s, :toggle_classes => ['btn pingB', 'pinged']}, :status => 201}
    else
      response = {:json => {:status => 'error', :message => 'Target user not found!'}, :status => 404}
    end

    respond_to do |format|
      format.json { render response }
    end
  end
end