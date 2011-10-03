module UsersHelper

  def user_link(user, length=nil)
    name = if length then truncate(user.fullname, :length => length, :omission => '..') else user.fullname end
    render "users/link", :user => user, :name => name
  end

end
