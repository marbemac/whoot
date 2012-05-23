class ShoutsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def create
    post = Post.current_post(current_user)

    event = post.shout(params[:content], current_user)
    if event
      if post.save
        Resque.enqueue(SendShoutEmail, current_user.id.to_s, params[:content])
        response = build_ajax_response(:ok, nil, "Your shout has been sent!")
      else
        response = build_ajax_response(:error, nil, "Your shout could not be posted", event.errors)
        status = 422
      end
    else
      response = build_ajax_response(:error, nil, "You have already shouted!")
      status = 422
    end

    render :json => response, :status => status
  end
end