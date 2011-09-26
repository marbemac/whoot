class UsersController < ApplicationController

  def show
    @user = User.find_by_encoded_id(params[:id])
  end

end
