web:         bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker:      bundle exec rake resque:work QUEUE=popularity,soulmate_venue,soulmate_user,soulmate_tag,images,notifications,slow
scheduler:   bundle exec rake resque:scheduler