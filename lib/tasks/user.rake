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

  desc "Re-fetch every users school info from Facebook."
  task :rebuild_schools => :environment do
    users = User.where(:status => 'Active')
    users.each do |user|
      user.schools = nil
      fb = user.facebook
      if fb
        me = fb.get_object("me")
        if me
          if me['education']
            me['education'].each do |e|
              data = {:type => e['type']}
              if e['school']
                data[:fb_id] = e['school']['id']
                data[:name] = e['school']['name']
                print "#{user.fullname} has school #{data[:name]}.\n"
              end
              if e['year']
                data[:year] = e['year']['name']
              end

              user.add_school(data)
            end
            user.save
          else
            print "ERROR - #{user.id.to_s} - #{user.fullname} has no FB education info.\n"
          end
        else
          print "ERROR - #{user.id.to_s} - #{user.fullname} could not get FB data.\n"
        end
      else
        print "ERROR - #{user.id.to_s} - #{user.fullname} has no FB.\n"
      end
    end
  end

  desc "Calculate user school stats."
  task :school_stats => :environment do
    users = User.where(:status => 'Active')
    stats = {}
    users.each do |user|

    end
  end

end