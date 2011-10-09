web:         bundle exec rails server thin -p $PORT
scheduler:   exec bundle exec rake resque:scheduler
worker:      exec bundle exec rake resque:work QUEUE=images,notifications