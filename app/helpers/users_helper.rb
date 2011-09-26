module UsersHelper

  def user_link(user, length)
    render "users/link", :user => user, :name => truncate(user.fullname, :length => length, :omission => '..')
  end

end
