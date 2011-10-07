web:         bundle exec rails server thin -p $PORT
scheduler:   bundle exec rake resque:scheduler
worker:      bundle exec rake resque:work QUEUE=scout,images