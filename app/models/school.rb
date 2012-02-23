class School
  include Mongoid::Document

  field :fb_id
  field :name
  field :type
  field :year

  embedded_in :user

end