object @post

attributes :tag,
           :night_type,
           :comment_count,
           :votes,
           :address_original,
           :venue,
           :location,
           :created_at

node(:id) do |post|
  post.id.to_s
end

node(:created_at_pretty) do |post|
  pretty_time(post.created_at)
end

node(:created_at_day) do |post|
  pretty_day(post.created_at)
end

child :user_snippet => :user do |post|
  extends "users/show"
end

child :post_events => :events do |post|
  extends "posts/post_event"
end

child :voters => :loop_ins do |post|
  extends "users/show"
end
