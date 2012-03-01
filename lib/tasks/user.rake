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

  desc "Output race scores"
  task :race_scores => :environment do
    User.order_by(:race_score, :desc).limit(20).each do |user|
      puts user.fullname + ": " + user.race_score.to_s
    end
  end

end