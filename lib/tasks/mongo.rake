namespace :mongo do

  desc "Seed the DB"
  task :seed do
    # LOCATIONS
    city = City.create(
            :name => "New York City",
            :state_code => "NY",
            :coordinates => [40.714623,-74.006605]
    )
  end

end