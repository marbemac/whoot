class FollowsController < ApplicationController
  before_filter :authenticate_user!

  def create
    target_user = User.find(params[:id])
    if target_user
      current_user.follow_user(target_user)
      if current_user.save && target_user.save
        @pubnub.publish({'channel' => target_user.id.to_s+'_private', 'message' => { :event => 'notification', :content => "#{current_user.fullname} is now following you." }})
      end
      if params[:format] == :api
        response = {:json => {:status => 'ok'}}
      else
        response = {:json => {:status => 'ok', :target => '.fol_'+target_user.id.to_s, :toggle_classes => ['followB', 'unfollowB']}, :status => 201}
      end
    else
      response = {:json => {:status => 'error', :message => 'Target user not found!'}, :status => 404}
    end

    render response
  end

  def destroy
    target_user = User.find(params[:id])
    if target_user
      current_user.unfollow_user(target_user)
      current_user.save
      target_user.save
      if params[:format] == :api
        response = {:json => {:status => 'ok'}}
      else
        response = {:json => {:status => 'ok', :target => '.fol_'+target_user.id.to_s, :toggle_classes => ['followB', 'unfollowB']}, :status => 201}
      end
    else
      response = {:json => {:status => 'error', :message => 'Target user not found!'}, :status => 404}
    end

    render response
  end
end