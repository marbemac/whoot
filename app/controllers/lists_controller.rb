class ListsController < ApplicationController
  before_filter :authenticate_user!

  def create
    list = current_user.lists.new(params[:list])

    if list.save
      response = { :redirect => list_path(list) }
      render json: response, status: :created, location: list
    else
      render json: list.errors, status: :unprocessable_entity
    end
  end

  def destroy
    list = List.find(params[:id])
    if list.user_id == current_user.id
      list.destroy
    end

    response = { :redirect => root_path }
    render json: response
  end

  def show
    @list = List.find(params[:id])
    if !@list || @list.user_id != current_user.id
      redirect_to root_path
    else
      @users = User.where(:_id.in => @list.list_users)
      @title = @list.name
      posts = NormalPost.list_feed(@list.list_users)
      @posts_with_user = User.join(posts)
    end
  end

  def add_user
    list = List.find(params[:id])
    user = User.find(params[:user_id])
    if list && user && current_user.id == list.user_id
      list.add_user(user)
      list.save
      response = {:json => {:status => 'ok', :redirect => list_path(list)}, :status => 201}
    else
      response = {:json => {:status => 'error', :message => 'Error!'}, :status => 404}
    end

    render response
  end

  def remove_user
    list = List.find(params[:id])
    user = User.find(params[:user_id])
    if list && user && current_user.id == list.user_id
      list.remove_user(user)
      list.save
      response = {:json => {:status => 'ok', :redirect => list_path(list)}, :status => 201}
    else
      response = {:json => {:status => 'error', :message => 'Error!'}, :status => 404}
    end

    render response
  end
end