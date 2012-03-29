object @post_event

attributes :night_type,
           :venue_id,
           :venue_name,
           :comment,
           :tag

node(:id) do |event|
  event.id.to_s
end

node(:type) do |event|
  event._type
end

node(:created_at_pretty) do |event|
  pretty_time(event.created_at)
end

child :user_snippet => :user do |event|
  extends "users/show"
end