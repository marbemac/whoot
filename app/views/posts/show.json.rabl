object @post

attributes :tag,
           :night_type,
           :comment_count,
           :votes,
           :address_original,
           :location

child :user_snippet => :user do |post|
  extends "users/show"
end