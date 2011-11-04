class AttendsController < ApplicationController
  before_filter :authenticate_user!

  def create
    target_invite = InvitePost.find(params[:id])
    if target_invite
      target_invite.add_attending current_user
      response = {:json => {:status => 'ok', :target => '.attend_'+target_invite.id.to_s, :toggle_classes => ['attendB', 'unattendB']}, :status => 201}
    else
      response = {:json => {:status => 'error', :message => 'Target invite not found!'}, :status => 404}
    end

    render response
  end

  def destroy
    target_invite = InvitePost.find(params[:id])
    if target_invite
      target_invite.remove_attending current_user
      response = {:json => {:status => 'ok', :target => '.attend_'+target_invite.id.to_s, :toggle_classes => ['attendB', 'unattendB']}, :status => 201}
    else
      response = {:json => {:status => 'error', :message => 'Target invite not found!'}, :status => 404}
    end

    render response
  end
end