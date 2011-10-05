class ListCell < Cell::Rails

  include Devise::Controllers::Helpers

  def sidebar_list
    @user = current_user
    @lists = List.where(:status => 'Active', :user_id => @user.id)

    render
  end


end