web:         bundle exec rails server thin -p $PORT
worker:      bundle exec rake resque:work QUEUE=images,notifications
scheduler:   bundle exec rake resque:scheduler