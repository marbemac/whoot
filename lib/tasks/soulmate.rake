namespace :soulmate do

  desc "Rebuild master users, following users, and master venues soulmate data."
  task :all => [:rebuild_users, :rebuild_users_following, :rebuild_venues]

  desc "Rebuild the master users soulmate."
  task :rebuild_users => :environment do
    include Rails.application.routes.url_helpers
    include SoulmateHelper

    users = User.where(:status => 'Active')

    soulmate_data = Array.new
    users.each do |user|
      soulmate_data << user_nugget(user)
    end
    Soulmate::Loader.new("user").load(soulmate_data)

    print "Loading #{soulmate_data.length} users into soulmate.\n"
    end

  desc "Rebuild each users following soulmate database."
  task :rebuild_users_following => :environment do
    include SoulmateHelper

    users = User.where(:status => 'Active')

    user_processed = 0
    following_processed = 0;
    users.each do |user|
      user_processed += 1
      if user.following_users_count > 0
        soulmate_data = Array.new
        following = User.where(:_id.in => user.following_users)
        following.each do |following_user|
          following_processed += 1
          soulmate_data << user_nugget(following_user)
        end
        Soulmate::Loader.new("#{user.id.to_s}").load(soulmate_data)
      end
    end

    print "Loading #{following_processed} followed users spread across #{user_processed} users into soulmate.\n"
  end

  desc "Rebuild the master venue soulmate database."
  task :rebuild_venues => :environment do
    include SoulmateHelper

    venues = Venue.where(:status => 'Active')

    venue_count = 0
    grouped_venues = {}
    venues.each do |venue|
      venue_count += 1
      grouped_venues[venue.city_id.to_s] << venue_nugget(venue)
    end

    grouped_venues.each_with_index do |soulmate_data, index|
      Soulmate::Loader.new("#{index}").load(soulmate_data)
    end

    print "Loading #{venue_count} venues into soulmate.\n"
  end
end