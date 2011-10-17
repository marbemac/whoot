namespace :user do

  desc "Set default user settings."
  task :rebuild_settings => :environment do
    users = User.where(:status => 'Active')
    users.each do |user|
      unless user.settings
        print "Loading #{user.fullname}'s' settings.\n"
        user.settings = UserSettings.new
        user.save
      end
    end
  end

end