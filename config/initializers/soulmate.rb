require 'soulmate/server'

if ENV["REDISTOGO_URL"]
  Soulmate.redis = ENV["REDISTOGO_URL"]
elsif Rails.env.development?
  Soulmate.redis = 'redis://127.0.0.1:6379/'
end