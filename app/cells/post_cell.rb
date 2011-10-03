class PostCell < Cell::Rails

  include Devise::Controllers::Helpers
  helper ImageHelper
  helper UsersHelper

  def create
    @user = current_user
    @my_post = NormalPost.current_post(@user)
    @venues = Venue.where(:status => 'Active', :city_id => @user.location.id).order(:slug, :asc)
    render
  end


end