class PostSnippet
  include Mongoid::Document

  field :night_type
  field :created_at, :type => Time

  embedded_in :user

end