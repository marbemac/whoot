class FollowsController < ApplicationController
  before_filter :authenticate_user!

  def create
    target_user = User.find(params[:id])
    if target_user
      current_user.follow_user(target_user)
      if current_user.save && target_user.save
        pusher_publish(target_user.id.to_s, 'notification', {:content => "#{current_user.fullname} is now following you."})
      end
      response = {:json => {:status => 'ok', :target => '.fol_'+target_user.id.to_s, :toggle_classes => ['followB', 'unfollowB']}, :status => 201}
    else
      response = {:json => {:status => 'error', :message => 'Target user not found!'}, :status => 404}
    end

    respond_to do |format|
      format.json { render response }
    end
  end

  def destroy
    target_user = User.find(params[:id])
    if target_user
      current_user.unfollow_user(target_user)
      current_user.save
      target_user.save
      response = {:json => {:status => 'ok', :target => '.fol_'+target_user.id.to_s, :toggle_classes => ['followB', 'unfollowB']}, :status => 201}
    else
      response = {:json => {:status => 'error', :message => 'Target user not found!'}, :status => 404}
    end

    respond_to do |format|
      format.json { render response }
    end
  end
end