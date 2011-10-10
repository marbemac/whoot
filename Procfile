web:         bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker:      bundle exec rake resque:work QUEUE=images,notifications
scheduler:   bundle exec rake resque:scheduler