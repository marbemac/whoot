object @post

attributes :tag,
           :night_type,
           :comment_count,
           :votes,
           :address_original,
           :venue,
           :location

node(:id) do |post|
  post.id.to_s
end

child :user_snippet => :user do |post|
  extends "users/show"
end

child :voters => :loop_ins do |post|
  extends "users/show"
end
