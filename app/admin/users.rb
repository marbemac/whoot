#ActiveAdmin.register User do
#
#  scope :inactive
#
#  form do |f|
#    f.inputs "Details" do
#      f.input :username
#      f.input :first_name
#      f.input :last_name
#      f.input :gender
#      f.input :email
#    end
#    f.buttons
#  end
#
#  index do
#    column :first_name
#    column :last_name
#    column :gender
#    column :email
#    column :created_at
#    column "Current Location" do |user|
#      if user.location then user.location.full else '--' end
#    end
#    column "Followers", :followers_count
#    column "Following", :following_users_count
#    column "Sign Ins", :sign_in_count
#    column "Last Sign In", :current_sign_in_at
#  end
#
#  show do
#    h3 user.fullname
#    div do
#      simple_format user.email
#    end
#  end
#
#  member_action :show, :method => :get do
#    @user = User.find_by_encoded_id(params[:id])
#  end
#
#  member_action :edit, :method => :get do
#    @user = User.find_by_encoded_id(params[:id])
#  end
#
#  member_action :update, :method => :put do
#    @user = User.find_by_encoded_id(params[:id])
#
#    @user.update_attributes(username: 'blah')
#    @user.save!
#
#    redirect_to git_er_done_user_path @user
#  end
#
#end
