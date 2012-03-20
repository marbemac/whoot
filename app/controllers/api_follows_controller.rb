class ApiFollowsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def create
    target = User.find(params[:id])
    if current_user && target
      if current_user.follow_user(target)
        current_user.save
        target.save

        response = build_ajax_response(:ok, nil, "You're following #{target.first_name}", nil, { })
        status = 201
      else
        response = build_ajax_response(:error, nil, "You're already following that!")
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

        response = build_ajax_response(:ok, nil, nil, nil, { })
        status = 201
       else
        response = build_ajax_response(:error, nil, "You're not following that!")
        status = 401
      end
    else
      response = build_ajax_response(:error, nil, 'Target user not found!')
      status = 404
    end

    render :json => response, :status => status
  end

end