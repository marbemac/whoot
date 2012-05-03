class ApiFollowsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def create
    target = User.find(params[:id])
    if current_user && target
      if current_user.follow_user(target)
        current_user.save
        target.save

        notification = Notification.add(target, :follow, true, current_user)
        if notification
          Pusher["#{target.id.to_s}_private"].trigger('new_notification', notification.to_json)
        end

        response = build_ajax_response(:ok, nil, "You're now following #{target.first_name}", nil, { })
        status = 201
      else
        response = build_ajax_response(:error, nil, "You're already following #{target.first_name}!")
        status = 401
      end
    else
      response = build_ajax_response(:error, nil, 'Target not found!')
      status = 404
    end

    render :json => response, :status => status
  end

  def destroy
    target = User.find(params[:id])
    if current_user && target
      if current_user.unfollow_user(target)
        current_user.save
        target.save
        Notification.remove(target, :follow, current_user)

        response = build_ajax_response(:ok, nil, "You're no longer following #{target.first_name}!", nil, { })
        status = 200
       else
        response = build_ajax_response(:error, nil, "You're not following #{target.first_name}!")
        status = 401
      end
    else
      response = build_ajax_response(:error, nil, 'Target user not found!')
      status = 404
    end

    render :json => response, :status => status
  end

end