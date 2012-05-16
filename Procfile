web:         bundle exec rails server thin -p $PORT -e $RACK_ENV
worker:      bundle exec rake resque:work QUEUE=popularity,soulmate_venue,soulmate_user,soulmate_tag,images,notifications,mailer,slow
scheduler:   bundle exec rake resque:scheduler